# check man zshzle and man zshcontrib for more details about the widgets

# lower the change mode delay when hitting ESC from 0.4 seconds default to 0.1
# OBS.: try rising the value if experiencing any issues
export KEYTIMEOUT=1

# start vi-mode
#bindkey -v
setopt vi

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

# put the cursor in I-beam shape
function fix_cursor() {
  printf '\033[6 q'
}

function change-hack() {
  local active=${REGION_ACTIVE:-0}
  local option

  # put cursor in underscore shape
  printf '\033[4 q'

  # if on visual mode simply change selection
  if (( $active == 1 || $active == 2 )); then
    zle vi-change
    return
  fi

  zle -R ">${NUMERIC}c_"
  read -k option

  if ! [[ $option =~ [[:cntrl:]] ]]; then
    zle -R ">${NUMERIC}c$option"
  fi

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
  local option

  # if on visual mode simply delete selection
  if (( $active == 1 || $active == 2 )); then
    zle vi-delete
    return
  fi

  zle -R ">${NUMERIC}d_"
  read -k option

  if ! [[ $option =~ [[:cntrl:]] ]]; then
    zle -R ">${NUMERIC}d$option"
  fi

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
  local option

  # if on visual mode simply yank selection
  if (( $active == 1 || $active == 2 )); then
    zle vi-yank
    return
  fi

  zle -R ">${NUMERIC}y_"
  read -k option

  if ! [[ $option =~ [[:cntrl:]] ]]; then
    zle -R ">${NUMERIC}y$option"
  fi

  if [[ $option == 's' ]]; then
    zle -U Tys
  elif [[ $option == 'y' ]]; then
    zle vi-yank-whole-line
  else
    zle -U ${NUMERIC}Tvy$option
  fi
}

function vim_sneak() {
  local search
  local tmpchar
  local buffer_bak
  local -a region_highlight_bak
  local -a matching_pos
  local -a alt_chars

  # Read exactly 2 characters from the user while showing what's
  # already been typed and save them in the match variable
  for (( i = 0; i < 2; i++ )); do
    zle -R ">${search}_"
    read -k tmpchar
    # Abort if the user typed any non printable character
    if [[ $tmpchar =~ [[:cntrl:]] ]]; then
      return 1
    else
      search+="$tmpchar"
    fi
  done
  zle -R ">${search}"

  # Go through BUFFER starting from the current cursor position
  # searching for matches and populate the matching_pos array with
  # its absolute position when found.
  # - If the user activated the widget with lowercase s, go through the
  #  right portion of the BUFFER, from left to right.
  # - Otherwise (user typed uppercase S), go through the left portion
  #  of the  BUFFER, from right to left.
  if [[ $KEYS == 's' ]]; then
    for (( i = 2; i < $#RBUFFER; i++ )); do
      if [[ $RBUFFER[i] == $search[1] ]] &&
         [[ $RBUFFER[i+1] == $search[2] ]]; then
        matching_pos+=( $(( CURSOR + i )) )
        i=$(( i + 1 ))
      fi
    done
  else
    for (( i = $#LBUFFER - 1; i > 0; i-- )); do
      if [[ $LBUFFER[i] == $search[1] ]] &&
         [[ $LBUFFER[i+1] == $search[2] ]]; then
        matching_pos+=( $i )
        i=$(( i - 1 ))
      fi
    done
  fi

  # Abort if no matches were found
  if (( $#matching_pos == 0 )); then
    return 1
  fi

  # alt_chars array starts with an empty value, so its indexes coincide
  # with matching_pos indexes in a way that from the second match on,
  # matching_pos index maps to the correct alt_char:
  # +--------------+-----------+-----------+-----------+-----------+
  # | index        |     1     |     2     |     3     |     4     | ...
  # +--------------+-----------+-----------+-----------+-----------+
  # | matching_pos | 1st match | 2nd match | 3rd match | 4th match | ...
  # +--------------+-----------+-----------+-----------+-----------+
  # | alt_chars    |           |     ;     |     s     |     f     | ...
  # +--------------+-----------+-----------+-----------+-----------+
  # This way, if we want update the BUFFER on the third match for example,
  # all that's need to be done is BUFFER[matching_pos[3]]=$alt_chars[3]
  alt_chars=( '' ';' 's' 'f' 't' 'u' 'n' 'q' '/' 'S' 'F'
    'G' 'H' 'L' 'T' 'U' 'N' 'R' 'M' 'Q' 'Z' '?' '0' )
  # Save the current value of BUFFER and region_highlight, because
  # they'll be needed inside the anonymous function bellow
  buffer_bak=$BUFFER
  region_highlight_bak=( $region_highlight )

  # Use anonymous function so BUFFER and region_highlight get restored
  # to their original values when the function exit, be it by normal
  # execution flow or if it is interrupted by any signal
  () {
    local +h BUFFER
    local +h region_highlight
    local -a highlight
    local starting_pos
    local ending_pos
    local index

    # Assign the previous values to the variables since they
    # are empty inside here after the local declaration above
    BUFFER=$buffer_bak
    region_highlight=( $region_highlight_bak )

    # CURSOR needs to be set after BUFFER, because while BUFFER
    # is empty, CURSOR can't be greater than 0
    CURSOR=$(( matching_pos[1] - 1 ))

    # If there were more than 1 match
    if (( $#matching_pos > 1 )); then
      # Mark the characters and highlight from the second match on to be changed
      for (( i = 2; i <= $#matching_pos && i <= $#alt_chars; i++ )); do
        BUFFER[matching_pos[i]]=$alt_chars[i]
        BUFFER[matching_pos[i]+1]=' '
        starting_pos=$(( matching_pos[i] - 1 ))
        ending_pos=$(( matching_pos[i] + 1 ))
        highlight+=( "$starting_pos $ending_pos bg=10,fg=0" )
      done

      # Mark the first match to be highlighted
      highlight+=( "$CURSOR $(( CURSOR + 1 )) bg=9" )

      # Update BUFFER and the CURSOR position on the screen, since modifying
      # their values does't update the user prompt in real time
      zle redisplay

      # Apply the highlight in fact. The zle -R needs to be re-executed
      # because the zle redisplay clears the prompt. Also, the highlight
      # doesn't work if we don't execute it ¯\_(ツ)_/¯
      region_highlight=( $region_highlight_bak $highlight )
      zle -R ">${search}"

      # Read if the user want to jump to any other match
      read -k tmpchar

      # Check if the user typed any character that's in alt_chars array:
      # - If so, jump the CURSOR to its respective position
      # - Otherwise, exec it as if the user typed it outside the widget
      index=$(( $alt_chars[(Ie)$tmpchar] ))
      if (( index != 0 )); then
        # zle redisplay doesn't need to be called to update the CURSOR
        # position here, because the prompt will be redisplayed anyway
        # when the widget finishes its execution
        CURSOR=$(( matching_pos[index] - 1 ))
      else
        zle -U $tmpchar
      fi
    fi
  }

  # Return the return value from the anonymous function above.
  # It will always be 0 unless it was interrupted by some signal
  return $?
}

function inc_dec_number() {
  # Indicate that the widget represents a change that can be repeated
  zle -f vichange

  # Needed by hex numbers matchings routines
  setopt extendedglob

  local bend
  local bpos
  local hex
  local number
  local operation
  local prefix
  local raw_number
  local result

  # CTRL-A for incrementing and CTRL-X for decrementing
  [[ "$KEYS" == $'\C-A' ]] && operation='+' || operation='-'

  # Check if the cursor is under a hexa number
  if [[ $LBUFFER${RBUFFER[1]} =~ '((0[xX])([0-9a-fA-F]+))$' ]] ||
     [[ $LBUFFER${RBUFFER::2} =~ '((0[xX]))[0-9a-fA-F]$' ]]; then
    bpos=$mbegin[1]
    bend=$mend[1]
    raw_number=$match[3]
    number=$match[1]
    prefix=$match[2]

    # Check if the hexa number continues after the cursor
    if [[ ${RBUFFER:1} =~ '^[0-9a-fA-F]+' ]]; then
      bend=$(( bend + MEND ))
      raw_number+=$MATCH
      number+=$MATCH
    fi

    # Implements vim logic for the result's case: if the last letter
    # is upper case, than the whole result will also be. extendedglob
    # was set in the beginning of the widget to allow the use of the
    # '#' which's equivalent to '*' in a regex (matches zero or more
    # occurrences of the last match).
    [[ $number == *[[:upper:]][[:digit:]]# ]] && hex='X' || hex='x'

    # Vim always keep the result with at least the same lenght of
    # the original hexa number, padding with zero if necessary
    result=$(printf "%.$#raw_number$hex" "$number $operation ${NUMERIC:-1}")
    BUFFER="${BUFFER::$bpos-1}$prefix$result${BUFFER:$bend}"
    CURSOR=$(( bpos + $#result ))

  # Check if there's a hexa number after the cursor
  elif [[ $RBUFFER =~ '(0[xX])([0-9a-fA-F]+)' ]]; then
    # Implements vim logic for the result's case: if the last letter
    # is upper case, than the whole result will also be. extendedglob
    # was set in the beginning of the widget to allow the use of the
    # '#' that's equivalent to '*' in a regex (matches zero or more
    # occurrences of the last match).
    [[ $MATCH == *[[:upper:]][[:digit:]]# ]] && hex='X' || hex='x'

    # Vim always keep the result with at least the same lenght of
    # the original hexa number, padding with zero if necessary
    result=$(printf "%.$#match[2]$hex" "$MATCH $operation ${NUMERIC:-1}")
    RBUFFER="${RBUFFER::$MBEGIN-1}$match[1]$result${RBUFFER:$MEND}"
    CURSOR=$(( CURSOR + MBEGIN + $#result ))
  # Check if the cursor is under a decimal number
  elif [[ $LBUFFER${RBUFFER[1]} =~ '-?([0-9]+)$' ]]; then
    bpos=$MBEGIN
    bend=$MEND
    raw_number=$match[1]
    number=$MATCH

    # Check if the decimal number continues after the cursor
    if [[ ${RBUFFER:1} =~ '^[0-9]+' ]]; then
      bend=$(( bend + MEND ))
      raw_number+=$MATCH
      number+=$MATCH
    fi

    result=$(( number $operation ${NUMERIC:-1} ))

    # Vim only keeps the result with at least the same lenght of the
    # original decimal number if it was already zero padded. Here,
    # we use -Z flag to pad the result, instead of printf as done in
    # the hexa case, taking into account the minus signal
    typeset -i -Z $(( (${raw_number[1]} == 0) * ($#raw_number + (result < 0)) )) result

    BUFFER="${BUFFER::$bpos-1}$result${BUFFER:$bend}"
    CURSOR=$(( bpos + $#result - 2 ))

  # Check if there's a decimal number after the cursor
  elif [[ $RBUFFER =~ '-?([0-9]+)' ]]; then
    result=$(( MATCH $operation ${NUMERIC:-1} ))

    # Vim only keeps the result with at least the same lenght of the
    # original decimal number if it was already zero padded. Here,
    # we use -Z flag to pad the result, instead of printf as done in
    # the hexa case, taking into account the minus signal
    typeset -i -Z $(( (${match[1][1]} == 0) * ($#match[1] + (result < 0)) )) result

    RBUFFER="${RBUFFER::$MBEGIN-1}$result${RBUFFER:$MEND}"
    CURSOR=$(( CURSOR + MBEGIN + $#result - 2 ))
  else
    return 1
  fi

  return 0
}

# overwrite builtin select-quoted, patching it to work on multiple lines
function select-quoted() {
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
function surround() {
  setopt localoptions noksharrays
  autoload -Uz select-quoted select-bracketed
  local before after
  local -A matching
  matching=(\( \) \{ \} \< \> \[ \])
  zle -f vichange
  case $WIDGET in
    (change-*)
      local MARK="$MARK"
      local save_cur="$CURSOR"
      local CURSOR="$CURSOR"
      local call

      zle -R ">${NUMERIC}cs_"
      read -k before

      if ! [[ $before =~ [[:cntrl:]] ]]; then
        zle -R ">${NUMERIC}cs${before}_"
      fi

      if [[ ${(kvj::)matching} = *$before* ]]; then
        call=select-bracketed
      else
        call=select-quoted
      fi

      read -k after

      if ! [[ $after =~ [[:cntrl:]] ]]; then
        zle -R ">${NUMERIC}cs${before}${after}"
      fi

      $call "a$before" || return 1
      before="$after"

      if [[ -n $matching[$before] ]]; then
        after="$matching[$before]"
      elif [[ -n $matching[(r)[$before:q]] ]]; then
        before="${(k)matching[(r)[$before:q]]}"
      fi

      BUFFER[CURSOR]="$after"
      BUFFER[MARK+1]="$before"
      CURSOR=$save_cur
      ;;
    (delete-*)
      local MARK="$MARK"
      local save_cur="$CURSOR"
      local CURSOR="$CURSOR"
      local call

      zle -R ">${NUMERIC}ds_"
      read -k before

      if ! [[ $before =~ [[:cntrl:]] ]]; then
        zle -R ">${NUMERIC}ds${before}"
      fi

      if [[ ${(kvj::)matching} = *$before* ]]; then
        call=select-bracketed
      else
        call=select-quoted
      fi

      if $call "a$before"; then
        BUFFER[CURSOR]=''
        BUFFER[MARK+1]=''
        CURSOR=$save_cur
      fi
      ;;
    (add-*)
      local save_cut="$CUTBUFFER"
      local save_cur="$CURSOR"
      local cursor_end=1

      if (( CURSOR < MARK )); then
        cursor_end=0
      fi

      if ! zle .vi-change; then
        return 1
      fi

      zle .vi-cmd-mode
      zle -R ">${CUTBUFFER}_"
      read -k before

      if [[ $before =~ [[:cntrl:]] ]]; then
        BUFFER="${BUFFER::$CURSOR+1}${CUTBUFFER}${BUFFER:$CURSOR+1}"
        CURSOR=$(( CURSOR + ${#CUTBUFFER} ))
        CUTBUFFER="$save_cut"
        return 1
      fi

      after="$before"

      if [[ -n $matching[$before] ]]; then
        after=" $matching[$before]"
        before+=' '
      elif [[ -n $matching[(r)[$before:q]] ]]; then
        before="${(k)matching[(r)[$before:q]]}"
      fi

      CUTBUFFER="$before$CUTBUFFER$after"

      if [[ CURSOR -eq 0 || $BUFFER[CURSOR] = $'\n' ]]; then
        zle .vi-put-before -n 1
      else
        zle .vi-put-after -n 1
      fi

      if (( cursor_end == 1 )); then
        CURSOR=$(( save_cur + ${#before} + ${#after} ))
      else
        CURSOR="$save_cur"
      fi

      CUTBUFFER="$save_cut"
      ;;
  esac
}

function goto-line() {
  if [[ -n $NUMERIC ]]; then
    if (( NUMERIC < 1 )); then
      CURSOR=0
    else
      local -a bol
      bol[1]=0

      # Save the position of all beginning of lines
      for (( pos = 1; pos <= $#BUFFER; pos++ )); do
        if [[ $BUFFER[pos] == $'\n' ]]; then
          bol[(( $#bol + 1 ))]=$pos
        fi
      done

      # Check if the desired destination line is
      # greater than the actual number of lines
      if (( NUMERIC > $#bol )); then
        CURSOR=$(( $#BUFFER - 1 ))
      else
        local line_lenght
        local column
        column=0

        # Calculate the cursor column in the current line
        for (( pos = $#LBUFFER; pos >= 0; pos-- )); do
          # Order of condition is important,
          # since LBUFFER starts at index 1
          if (( pos == 0 )) || [[ $LBUFFER[pos] == $'\n' ]]; then
            column=$(( $#LBUFFER - pos ))
            break
          fi
        done

        if (( NUMERIC < $#bol )); then
          line_lenght=$(( bol[NUMERIC + 1] - bol[NUMERIC] - 2 ))
        else
          line_lenght=$(( $#BUFFER - bol[NUMERIC] - 1 ))
        fi

        # In some weird cases line_lenght may become -1
        if (( line_lenght < 0 )); then
          line_lenght=0
        fi

        if (( column > line_lenght)); then
          column=$line_lenght
        fi

        # Move to the desired line keeping the same column offset
        CURSOR=$(( bol[$NUMERIC] + column ))
      fi
    fi
  elif [[ $KEYS == 'gg' ]]; then
    CURSOR=0
  elif [[ $KEYS == 'G' ]]; then
    CURSOR=$(( $#BUFFER - 1 ))
  fi
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
zle -N vim_sneak
bindkey -M vicmd 's' vim_sneak
bindkey -M vicmd 'S' vim_sneak

# C-A adds [NUMERIC] to the number at or after the cursor
# and C-X decrements it. It works for decimal numbers
zle -N inc_dec_number
bindkey -M vicmd '^A' inc_dec_number
bindkey -M vicmd '^X' inc_dec_number

# enable addition of surroundings to a text
# normal mode: ys<movement><symbol>
# visual mode: S<symbol>
zle -N add-surround surround
bindkey -M vicmd 'Tys' add-surround
bindkey -M visual 'S' add-surround

# enable edition/deletion of surrounded text
# edit: cs<before><after>
zle -N change-surround surround
bindkey -M vicmd 'Tcs' change-surround

# enable edition/deletion of surrounded text
# deletion: ds<symbol>
zle -N delete-surround surround
bindkey -M vicmd 'Tds' delete-surround

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

# gg and G moves to the beginning and end of tex, respectively
zle -N goto-line
bindkey -M vicmd 'gg' goto-line
bindkey -M vicmd 'G' goto-line

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

# alt-[0-9] in insert mode and [0-9] in normal mode set the digit argument
function vi-digit-argument() {
  local tmpchar=$KEYS
  local number=$KEYS

  while [[ "$tmpchar" == [0-9] ]]; do
    zle digit-argument
    zle -R ">${number}_"
    read -k tmpchar
    number+=$tmpchar
  done

  # If the last character read is printable, update the prompt
  if ! [[ $tmpchar =~ [[:cntrl:]] ]]; then
    zle -R ">${number}_"
  fi
  zle -U $tmpchar
}
zle -N vi-digit-argument
for digit in {1..9}; do
  bindkey -M vicmd "$digit" vi-digit-argument
done

# alt-. insert the last word from the previous command (!$)
function vi-insert-last-word() {
  if [[ $KEYMAP == 'vicmd' ]]; then
    CURSOR=$(( CURSOR + 1 ))
    zle -K 'viins'
  fi

  if (( NUMERIC > 0 )); then
    zle insert-last-word -- -${NUMERIC} -1
  else
    zle insert-last-word -- -1
  fi
}
zle -N vi-insert-last-word
bindkey -M viins '^[.' vi-insert-last-word
bindkey -M vicmd '^[.' vi-insert-last-word

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
#bindkey -M vicmd '^I' fasd-complete

function custom-prompt-widget() {
    # Local variables for prompt, input, and cursor management
    local prompt="Enter your text: "
    local input=""
    local cursor=0
    local input_length=0

    # Clipboard for cut words
    local word_clipboard=""

    # Clear the command line
    zle kill-whole-line

    # Initial display of prompt
    zle -R "$prompt"

    # Input reading and processing loop
    while true; do
        # Read a single character
        local char
        read -k 1 char

        # Decode input and handle special shortcuts
        case "$char" in
            $'\x01')  # CTRL-a: Move to beginning of line
                cursor=0
                zle -R "$prompt$input"
                continue
                ;;

            $'\x05')  # CTRL-e: Move to end of line
                cursor=$input_length
                zle -R "$prompt$input"
                continue
                ;;

            $'\x17')  # CTRL-w: Cut previous word
                if (( cursor > 0 )); then
                    # Find the start of the previous word
                    local word_start=$cursor
                    while (( word_start > 0 )) && [[ "${input:word_start-1:1}" == [[:space:]] ]]; do
                        ((word_start--))
                    done
                    while (( word_start > 0 )) && [[ "${input:word_start-1:1}" != [[:space:]] ]]; do
                        ((word_start--))
                    done

                    # Cut the word to clipboard
                    word_clipboard="${input:word_start:cursor-word_start}"

                    # Remove the word
                    input="${input:0:word_start}${input:cursor}"
                    input_length=$((input_length - (cursor - word_start)))
                    cursor=$word_start
                    zle -R "$prompt$input"
                fi
                continue
                ;;

            $'\x19')  # CTRL-y: Paste cut word
                if [[ -n "$word_clipboard" ]]; then
                    # Insert clipboard content at cursor
                    if (( cursor == input_length )); then
                        # Append at end
                        input+="$word_clipboard"
                    else
                        # Insert in middle
                        input="${input:0:cursor}$word_clipboard${input:cursor}"
                    fi

                    # Update cursor and input length
                    ((cursor += ${#word_clipboard}))
                    ((input_length += ${#word_clipboard}))
                    zle -R "$prompt$input"
                fi
                continue
                ;;

            $'\x1b')
                # Escape sequence handling
                read -k 1 -t 0.01 next_char
                if [[ -n "$next_char" ]]; then
                    read -k 1 -t 0.01 third_char

                    # Arrow key handling
                    case "$next_char$third_char" in
                        "[A")  # Up arrow
                            ;;
                        "[B")  # Down arrow
                            ;;
                        "[C")  # Right arrow
                            if (( cursor < input_length )); then
                                ((cursor++))
                                zle -R "$prompt$input"
                            fi
                            ;;
                        "[D")  # Left arrow
                            if (( cursor > 0 )); then
                                ((cursor--))
                                zle -R "$prompt$input"
                            fi
                            ;;
                        *)
                            # Unhandled escape sequence
                            ;;
                    esac
                fi
                ;;

            $'\r' | $'\n')  # Enter key
                break
                ;;

            $'\b' | $'\177')  # Backspace/Delete
                if (( cursor > 0 )); then
                    # Remove character before cursor
                    input="${input:0:cursor-1}${input:cursor}"
                    ((cursor--))
                    ((input_length--))
                    zle -R "$prompt$input"
                fi
                ;;

            $'\x1b[3~')  # Delete key
                if (( cursor < input_length )); then
                    # Remove character at cursor
                    input="${input:0:cursor}${input:cursor+1}"
                    ((input_length--))
                    zle -R "$prompt$input"
                fi
                ;;

            *)
                # Handle printable characters
                if [[ "$char" == [[:print:]] ]]; then
                    # Insert character at cursor position
                    if (( cursor == input_length )); then
                        # Append at end
                        input+="$char"
                    else
                        # Insert in middle
                        input="${input:0:cursor}$char${input:cursor}"
                    fi

                    ((cursor++))
                    ((input_length++))
                    zle -R "$prompt$input"
                fi
                ;;
        esac
    done

    # Final processing
    zle kill-whole-line
    REPLY="$input"

    # Optional: print input (can be removed if not needed)
    echo "$input"

    return 0
}
zle -N custom-prompt-widget
bindkey -M vicmd '^I' custom-prompt-widget

function foobar() {
  zle -R 'foo:'
  sleep 3
  zle -U Tve
}
zle -N foobar
bindkey -M vicmd '^I' foobar
bindkey -M vicmd 'Tve' execute-named-cmd
