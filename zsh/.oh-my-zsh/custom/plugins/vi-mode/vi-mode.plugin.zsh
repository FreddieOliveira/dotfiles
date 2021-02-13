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

# exec fix_cursor function every time before drawing the prompt
precmd_functions+=(fix_cursor)

# enable surround widget
autoload -Uz surround

# enable selection of surrounded text for surround zle widget
autoload -U select-bracketed
zle -N select-bracketed
for m in visual vicmd; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

autoload -U select-quoted
zle -N select-quoted
for m in visual vicmd; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
done

# enable edition/deletion of surrounded text
# edit: cs<before><after>
# deletion: ds<symbol>
zle -N delete-surround surround
zle -N change-surround surround
bindkey -M vicmd 'Tcs' change-surround
bindkey -M vicmd 'Tds' delete-surround

# enable addition of surroundings to a text
# normal mode: ys<movement><symbol>
# visual mode: ys<symbol>
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

# ctrl-r and ctrl-s to search the history
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# ctrl-u cut line from the cursor to its
# beginning instead of cutting the whole line
bindkey -M viins '^U' backward-kill-line

# ctrl-k cut the line from the cursor to the end in insert mode
bindkey -M viins '^K' kill-line

# alt-. to insert the last word from the previous command (!$)
bindkey -M viins '^[.' insert-last-word

# alt-d to cut the current word in insert mode
bindkey -M viins '^[d' kill-word

# ctrl-y to paste when in insert mode
bindkey -M viins '^Y' yank

# alt-b and alt-f to move one word backward/forward in insert mode
bindkey -M viins '^[b' backward-word
bindkey -M viins '^[f' forward-word

# allow to move back and forward chars while in insert mode
bindkey -M viins '^F' forward-char
bindkey -M viins '^B' backward-char

# to ctrl-d to delete the current char when in insert mode
bindkey -M viins '^D' delete-char

# delete backward char even past the point where entered in insert mode
bindkey -M viins '^?' backward-delete-char

# delete backward word even past the point where entered in insert mode
bindkey -M viins '^W' backward-kill-word

# do history expansion with a space
bindkey ' ' magic-space

# TAB in normal mode performs a fasd expansiom
bindkey -M vicmd '^I' fasd-complete

