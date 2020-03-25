# check man zshzle and man zshcontrib for more details about the widgets

# lower the change mode delay when hitting ESC from 0.4 seconds default to 0.1
# OBS.: try rising the value if experiencing any issues
export KEYTIMEOUT=1

# start vi-mode
bindkey -v

# updates cursor shape on different modes
function zle-keymap-select() {
  if [[ $KEYMAP == 'vicmd' ]]; then
    printf '\033[?25h\033[2 q'
  elif [[ $KEYMAP =~ (viins|main) ]]; then
    printf '\033[?25h\033[6 q'
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

# exec fix_cursor function evertime before drawing the prompt
precmd_functions+=(fix_cursor)

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

# allow ctrl-r and ctrl-s to search the history
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# make ctrl-u cut line from the cursor to its
# beggining instead of cutting the whole line
bindkey -M viins '^U' backward-kill-line

# allow dd to cut the whole line instead of just deleting it
bindkey -M vicmd 'dd' kill-whole-line

# allow alt-. to insert the last word from the previous command (!$)
bindkey -M viins '^[.' insert-last-word

# allow alt-d to cut the current word in insert mode
bindkey -M viins '^[d' kill-word

# allow ctrl-y to paste when in insert mode
bindkey -M viins '^Y' yank

# allow alt-f to move one word forward while in insert mode
bindkey -M viins '^[f' forward-word

# allow to move back and forward chars while in insert mode
bindkey -M viins '^F' forward-char
bindkey -M viins '^B' backward-char

# allow to ctrl-d to delete the current char when in insert mode
bindkey -M viins '^D' delete-char

# delete backward char even past the point where entered in insert mode
bindkey -M viins '^?' backward-delete-char

# delete backward word even past the point where entered in insert mode
bindkey -M viins '^W' backward-kill-word

# ctrl-k cut the line from the cursor to the end in insert mode
bindkey -M viins '^K' kill-line

# do history expansion with a space
bindkey ' ' magic-space

