# check man zshzle and man zshcontrib for more details about the widgets

# lower the change mode delay when hitting ESC from 0.4 seconds default to 0.1
# OBS.: try rising the value if experiencing any issues
export KEYTIMEOUT=1

# start vi-mode
bindkey -v

# updates cursor shape on different modes
function zle-keymap-select() {
  if [[ $KEYMAP == 'vicmd' ]]; then
    printf '\033[2 q'
  elif [[ $KEYMAP =~ (viins|main) ]]; then
    printf '\033[6 q'
  fi
}

# updates cursor shape in single char overwrite mode
function single_replace() {
  printf '\033[4 q'
  zle vi-replace-chars
  printf '\033[2 q'
}

# updates cursor shape in multi char overwrite mode
function multi_replace() {
  zle vi-replace
  printf '\033[4 q'
}

# put the cursor in beam shape
function fix_cursor() {
  printf '\033[6 q'
}

function change-hack() {
  local active=${REGION_ACTIVE:-0}

  # put cursor in underscore shape
  printf '\033[4 q'

  # if on visual mode simply change selection
  if (( $active == 1 || $active == 2 )); then
    zle vi-change
    return
  fi

  read -k 1 option

  if [[ $option == 's' ]]; then
    zle -U Tcs
  elif [[ $option == 'c' ]]; then
    zle vi-change-whole-line
  else
    zle -U ${NUMERIC}Tvc$option
  fi

  # change cursor shape accordingly
  # i.e. cc goes to insert mode, while cESC goes to normal mode
  zle-keymap-select
}

function delete-hack() {
  local active=${REGION_ACTIVE:-0}

  # if on visual mode simply delete selection
  if (( $active == 1 || $active == 2 )); then
    zle vi-delete
    return
  fi

  read -k 1 option

  if [[ $option == 's' ]]; then
    zle -U Tds
  elif [[ $option == 'd' ]]; then
    zle kill-whole-line
  else
    zle -U ${NUMERIC}Tvd$option
  fi
}

function yank-hack() {
  local active=${REGION_ACTIVE:-0}

  # if on visual mode simply yank selection
  if (( $active == 1 || $active == 2 )); then
    zle vi-yank
    return
  fi

  read -k 1 option

  if [[ $option == 's' ]]; then
    zle -U Tys
  elif [[ $option == 'y' ]]; then
    zle vi-yank-whole-line
  else
    zle -U ${NUMERIC}Tvy$option
  fi
}

function vim_sneak_forward() {
  read -k 2 match

  # non greedy match
  if [[ $RBUFFER =~ [^${match[1]}]$match ]] && (( $MEND > 2 )); then
    CURSOR=$(( CURSOR + MEND - 2 ))
    return 0
  fi

  return 1
}

function vim_sneak_backward() {
  read -k 2 match

  # greedy match
  if [[ $LBUFFER =~ .*$match ]]; then
    CURSOR=$(( MEND - 2 ))
    return 0
  fi

  return 1
}

# overwrite builtin select-quoted, patching it to work on multiple lines
select-quoted () {
  setopt localoptions noksharrays
  local matching=${${1:-$KEYS}[2]}
  local -i start=CURSOR+2 end=CURSOR+2 found=0 alt=0 count=0
  if (( REGION_ACTIVE ))
  then
    if (( MARK < CURSOR ))
    then
      start=MARK+2
    else
      end=MARK+2
    fi
  fi
  [[ $BUFFER[CURSOR+1] = $matching && $BUFFER[CURSOR] != \\ ]] && count=1
  while (( (count || ! alt) && --start ))
  do
    if [[ $BUFFER[start] = "$matching" ]]
    then
      if [[ $BUFFER[start-1] = \\ ]]
      then
        (( start-- ))
      elif (( ! found ))
      then
        found=start
      else
        (( ! alt )) && alt=start
        (( count && ++count ))
      fi
    fi
  done
  for ((start=CURSOR+2; ! found && start+1 < $#BUFFER; start++ )) do
    case $BUFFER[start] in
      ($'\n') return 1 ;;
      (\\) (( start++ )) ;;
      ("$matching") (( end=start+1, found=start )) ;;
    esac
  done
  [[ $BUFFER[end-1] = \\ ]] && (( end++ ))
  until [[ $BUFFER[end] == "$matching" ]]
  do
    [[ $BUFFER[end] = \\ ]] && (( end++ ))
    if (( ++end > $#BUFFER ))
    then
      end=0
      break
    fi
  done
  if (( alt && (!end || count == 2) ))
  then
    end=found
    found=alt
  fi
  (( end )) || return 1
  [[ ${${1:-$KEYS}[1]} = a ]] && (( found-- )) || (( end-- ))
  (( REGION_ACTIVE = !!REGION_ACTIVE ))
  [[ $KEYMAP = vicmd ]] && (( REGION_ACTIVE && end-- ))
  MARK=found
  CURSOR=end
}

# overwrite builtin surround, patching it to not insert space around
# brackets and to keep the cursor position after the operations
surround () {
  setopt localoptions noksharrays
  autoload -Uz select-quoted select-bracketed
  local before after
  local -A matching
  matching=(\( \) \{ \} \< \> \[ \])
  zle -f vichange
  case $WIDGET in
    (change-*) local MARK="$MARK" save_cur=CURSOR="$CURSOR" call
      read -k 1 before
      if [[ ${(kvj::)matching} = *$before* ]]
      then
        call=select-bracketed
      else
        call=select-quoted
      fi
      read -k 1 after
      $call "a$before" || return 1
      before="$after"
      if [[ -n $matching[$before] ]]
      then
        after="$matching[$before]"
      elif [[ -n $matching[(r)[$before:q]] ]]
      then
        before="${(k)matching[(r)[$before:q]]}"
      fi
      BUFFER[CURSOR]="$after"
      BUFFER[MARK+1]="$before"
      CURSOR=$save_cur  ;;
    (delete-*) local MARK="$MARK" save_cur=CURSOR="$CURSOR" call
      read -k 1 before
      if [[ ${(kvj::)matching} = *$before* ]]
      then
        call=select-bracketed
      else
        call=select-quoted
      fi
      if $call "a$before"
      then
        BUFFER[CURSOR]=''
        BUFFER[MARK+1]=''
        CURSOR=$save_cur
      fi ;;
    (add-*) local save_cut="$CUTBUFFER"
      zle .vi-change || return
      local save_cur="$CURSOR"
      zle .vi-cmd-mode
      read -k 1 before
      after="$before"
      if [[ -n $matching[$before] ]]
      then
        after=" $matching[$before]"
        before+=' '
      elif [[ -n $matching[(r)[$before:q]] ]]
      then
        before="${(k)matching[(r)[$before:q]]}"
      fi
      CUTBUFFER="$before$CUTBUFFER$after"
      if [[ CURSOR -eq 0 || $BUFFER[CURSOR] = $'\n' ]]
      then
        zle .vi-put-before -n 1
      else
        zle .vi-put-after -n 1
      fi
      CUTBUFFER="$save_cut" CURSOR="$save_cur"  ;;
  esac
}


# exec fix_cursor function every time before drawing the prompt
precmd_functions+=(fix_cursor)

# enable surround widget
#autoload -Uz surround

# enable selection of surrounded text for surround zle widget
autoload -U select-bracketed
zle -N select-bracketed
for m in visual vicmd; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

#autoload -U select-quoted
zle -N select-quoted
for m in visual vicmd; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
done

# simulate 'justinmk/vim-sneak' plugin
zle -N vim_sneak_forward
zle -N vim_sneak_backward
bindkey -M vicmd 's' vim_sneak_forward
bindkey -M vicmd 'S' vim_sneak_backward

# enable edition/deletion of surrounded text
# edit: cs<before><after>
# deletion: ds<symbol>
zle -N delete-surround surround
zle -N change-surround surround
bindkey -M vicmd 'Tcs' change-surround
bindkey -M vicmd 'Tds' delete-surround

# enable addition of surroundings to a text
# normal mode: ys<movement><symbol>
# visual mode: S<symbol>
zle -N add-surround surround
bindkey -M vicmd 'Tys' add-surround
bindkey -M visual S add-surround

# these hacks are needed because of time conflicts between
# low KEYTIMEOUT values and 's' shortcut used for the surroundings
zle -N change-hack
zle -N delete-hack
zle -N yank-hack
bindkey -M vicmd 'c' change-hack
bindkey -M vicmd 'd' delete-hack
bindkey -M vicmd 'y' yank-hack
bindkey -M vicmd 'Tvd' vi-delete
bindkey -M vicmd 'Tvc' vi-change
bindkey -M vicmd 'Tvy' vi-yank

# register the widgets
zle -N single_replace
zle -N multi_replace
zle -N zle-keymap-select

# change cursor shape on replace mode
bindkey -M vicmd 'r' single_replace
bindkey -M vicmd 'R' multi_replace

# disable cycling through history when moving up/down
bindkey -M vicmd 'j' down-line
bindkey -M vicmd 'k' up-line

# make ctrl-j and crtl-m alias to ENTER
bindkey -M vicmd '^J' accept-line
bindkey -M vicmd '^M' accept-line

# navigate history with the beggining word
# cmd mode
bindkey -M vicmd '^P' up-line-or-beginning-search
bindkey -M vicmd '^N' down-line-or-beginning-search
bindkey -M vicmd '^[OA' up-line-or-beginning-search
bindkey -M vicmd '^[OB' down-line-or-beginning-search
# insert mode
bindkey -M viins '^P' up-line-or-beginning-search
bindkey -M viins '^N' down-line-or-beginning-search
bindkey -M viins '^[OA' up-line-or-beginning-search
bindkey -M viins '^[OB' down-line-or-beginning-search

# ctrl-r and ctrl-s search the history
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# ctrl-a and ctrl-e move to beginning/end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# ctrl-u cut line from the cursor to its
# beginning instead of cutting the whole line
bindkey -M viins '^U' backward-kill-line

# ctrl-k cut the line from the cursor to the end in insert mode
bindkey -M viins '^K' kill-line

# alt-. insert the last word from the previous command (!$)
bindkey -M viins '^[.' insert-last-word

# alt-d cut the current word in insert mode
bindkey -M viins '^[d' kill-word

# ctrl-y paste in insert mode
bindkey -M viins '^Y' yank

# alt-b and alt-f move one word backward/forward in insert mode
bindkey -M viins '^[b' backward-word
bindkey -M viins '^[f' forward-word

# ctrl-f and ctrl-b move backward/forward chars in insert mode
bindkey -M viins '^F' forward-char
bindkey -M viins '^B' backward-char

# ctrl-d delete the current char in insert mode
bindkey -M viins '^D' delete-char

# delete backward char even past the point where entered in insert mode
bindkey -M viins '^?' backward-delete-char

# delete backward word even past the point where entered in insert mode
bindkey -M viins '^W' backward-kill-word

# do history expansion with a space
bindkey ' ' magic-space

# TAB in normal mode performs a fasd expansiom
bindkey -M vicmd '^I' fasd-complete

