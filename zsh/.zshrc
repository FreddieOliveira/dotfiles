#                INITIALIZATION SETTINGS {{{1
#########################################################
# Autostart tmux if not already done it
if which tmux >/dev/null \
  && [[ -z "$ZSH_TMUX_AUTOSTARTED" \
  && -z "$TMUX" \
  && -z "$INSIDE_EMACS" \
  && -z "$EMACS" \
  && -z "$VIM" \
  && -z "$INTELLIJ_ENVIRONMENT_READER" \
  && -z "$ZED_TERM" ]]; then
    export ZSH_TMUX_AUTOSTARTED=true
    tmux attach &>/dev/null || tmux
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top
# of ~/.zshrc. Initialization code that may require console input
# (password prompts, [y/n] confirmations, etc.) must go above this
# block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
#########################################################
#               ENVIRONMENT VARIABLES {{{1
#########################################################
export EDITOR=nvim
export PATH="$HOME/.local/bin:$HOME/perl5/bin:$PATH"
export FZF_DEFAULT_OPTS="--height=75% --layout=reverse --exact --tiebreak=chunk,index --preview-window=down:80%:wrap:hidden --cycle --preview='preview.sh {}' --bind=ctrl-space:toggle-preview --hscroll-off=999 --keep-right"
export LESS='-R --mouse --ignore-case'
export LSCOLORS=Gxfxcxdxbxegedabagacad
if which dircolors >/dev/null; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi
# Disable the bahavior of deleting suffix chars (spaces and
# slashes) added by TAB auto completion. For further info, check
# https://superuser.com/questions/613685
#export ZLE_REMOVE_SUFFIX_CHARS=''
export ZLE_SPACE_SUFFIX_CHARS=$'&|'
#########################################################
#                    ZSH SETTINGS {{{1
#########################################################
# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000000
SAVEHIST=1000000000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
setopt CORRECT  # enable command spelling correction
setopt EXTENDEDGLOB

WORDCHARS=''
# Adopts the same behavior as sh when expanding variables
# depending on it's enclosed with quotes or not
#setopt shwordsplit
# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# Set descriptions format to enable group support NOTE: don't use
# escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore
# them
zstyle ':completion:*:descriptions' format '[%d]'
# Set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Force zsh not to show completion menu, which allows fzf-tab to
# capture the unambiguous prefix
zstyle ':completion:*' menu no
#zstyle ":completion:*" show-completer true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache"
# Enable completion inside /sdcard/
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

autoload -Uz compinit

# Load and initialize the completion system ignoring insecure
# directories with a cache time of 1 day
_comp_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
# man zshexpn (Glob Qualifiers)
if [[ $_comp_dump(#qNmd-1) ]]; then
  # -C (skip function check) implies -u (skip security check).
  compinit -C -d "$_comp_dump"
else
  mkdir -p "$_comp_dump:h"
  compinit -u -d "$_comp_dump"
  touch "$_comp_dump"
fi
unset _comp_dump

# Execute this block in the background and disowned
{
  autoload -Uz zrecompile
  _comp_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

  # Compile the completion database, plugins and .zshrc if not
  # not already or if outdated (plain text file is more recent
  # than compiled)
  zrecompile -q -p "$_comp_dump" -- \
    "$HOME/.config/zsh/vi-mode/vi-mode.plugin.zsh" -- \
    "$HOME/.config/zsh/fzf-tab/fzf-tab.plugin.zsh" -- \
    "$HOME/.config/zsh/fzf-tab/fzf-tab.zsh" -- \
    "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" -- \
    "$HOME/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" -- \
    "$HOME/.config/zsh/fasd/fasd.plugin.zsh" -- \
    "$HOME/.config/zsh/powerlevel10k/powerlevel9k.zsh-theme" -- \
    "$HOME/.zshrc"
} &!
#########################################################
#                   PLUGINS SETTINGS {{{1
#########################################################
#>----| powerlevel10k {{{2
################################
POWERLEVEL9K_MODE='nerdfont-v3'
POWERLEVEL9K_BACKGROUND_JOBS_ICON=''
POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
POWERLEVEL9K_VCS_GIT_ICON=''
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_STATUS_OK_BACKGROUND="black"
POWERLEVEL9K_STATUS_OK_FOREGROUND="40"
POWERLEVEL9K_STATUS_ERROR_BACKGROUND="black"
POWERLEVEL9K_STATUS_ERROR_FOREGROUND="196"
POWERLEVEL9K_STATUS_LEFT_LEFT_WHITESPACE=''
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="black"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="yellow"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_TIME_ICON=''
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='╭'
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='╰─'
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR="·"
POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status virtualenv background_jobs root_indicator dir newline)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vcs time command_execution_time)
POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
#POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders
POWERLEVEL9K_LEGACY_ICON_SPACING=true
ZLE_RPROMPT_INDENT=0
################################
#>----| zsh-autosuggestions {{{2
################################
# widgets that accept the suggestion as far as the cursor moves
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    forward-char
    vi-forward-char
    forward-word
    emacs-forward-word
    vi-forward-word
    vi-forward-word-end
    vi-forward-blank-word
    vi-forward-blank-word-end
    vi-find-next-char
    vi-find-next-char-skip
)

# widgets that accept the entire suggestion
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    end-of-line
    vi-end-of-line
    vi-add-eol
)
################################
#>----| fzf-tab {{{2
################################
zstyle ':fzf-tab:*' fzf-flags --height=75% --bind=ctrl-space:toggle-preview,tab:toggle+down --tiebreak=begin --preview-window=down:80%:nowrap:hidden --cycle -m
zstyle ':fzf-tab:complete:*:*' fzf-preview 'preview.sh $realpath'
# prevent populating fzf query. See https://github.com/Aloxaf/fzf-tab/issues/99
#zstyle ':fzf-tab:*' query-string prefix first
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
#########################################################
#                  PLUGINS SELECTION {{{1
#########################################################
# The order is important!
source "$HOME/.config/zsh/vi-mode/vi-mode.plugin.zsh"
eval "$(fzf --zsh)"
source "$HOME/.config/zsh/fzf-tab/fzf-tab.plugin.zsh"
source "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$HOME/.config/zsh/fasd/fasd.plugin.zsh"
source "$HOME/.config/zsh/powerlevel10k/powerlevel9k.zsh-theme"
#########################################################
#                   ALIASES DEFINITIONS {{{1
#########################################################
alias ta='tmux attach'
alias tl='tmux list-sessions'

# colorful ls
if which dircolors >/dev/null; then
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias eza='eza --color=automatic'
fi

# some more ls aliases
if which eza >/dev/null; then
  alias l='eza --icons --group-directories-first --all'
  alias ll='eza --icons --group-directories-first --long --group --classify --all'
else
  alias l='ls -A'
  alias ll='ls -alFh'
fi

# system clipboard copy and paste
if which xclip >/dev/null; then
    alias cp-clipbrd='xclip -selection clipboard'
    alias pt-clipbrd='xclip -selection clipboard -o'
elif which xsel >/dev/null; then
    alias cp-clipbrd='xsel --clipboard --input'
    alias pt-clipbrd='xsel --clipboard --output'
else
    if which termux-clipboard-set >/dev/null; then
        alias cp-clipbrd='termux-clipboard-set'
    elif which pbcopy >/dev/null; then
        alias cp-clipbrd='pbcopy'
    fi

    if which termux-clipboard-get >/dev/null; then
        alias pt-clipbrd='termux-clipboard-get'
    elif which pbpaste >/dev/null; then
        alias pt-clipbrd='pbpaste'
    fi
fi

alias lsblk='lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINT,SIZE,FSSIZE,FSUSED,FSAVAIL,FSUSE%,UUID,LABEL'

# htop and ngrok don't like the tmux-256color TERM
alias htop='TERM=xterm-256color htop'
alias ngrok='TERM=xterm-256color ngrok'

# useful apt commands with fzf
alias add="apt-cache search . | cut -d' ' -f1 | fzf --layout=reverse -m --cycle --height=65% --preview-window=down:75%:wrap:hidden --preview='apt show {} 2>/dev/null; dpkg-query -L {} 2>&1 | sort | tail -n +2 | while read cur; do [[ \$cur != \$prev/* ]] && echo \$prev; prev=\$cur; done; echo \$prev;' | xargs -ro pkg install"
alias del="dpkg-query --no-pager -W -f='\${binary:Package}\n' | cut -d' ' -f1 | fzf --layout=reverse -m --cycle --height=65% --preview-window=down:75%:wrap:hidden --preview='apt show {}=\$(dpkg-query --show {} | cut -f2) 2>/dev/null; dpkg-query -L {} | sort | tail -n +2 | while read cur; do [[ \$cur != \$prev/* ]] && echo \$prev; prev=\$cur; done; echo \$prev;' | xargs -ro apt purge"
#########################################################
#                 FUNCTIONS DEFINITIONS {{{1
#########################################################
# Override fzf plugin's widget which is called by CTRL+r shortcut
# (enhanced history-incremental-search-backward)
fzf-history-widget() { # {{{
  local selected fzf_default_opts ret

  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

  fzf_default_opts="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS//--keep-right/} -n2..,.. --exact --tiebreak=chunk,index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS -m"

  # https://stackoverflow.com/questions/72371540/is-there-a-way-to-split-a-string-into-an-array-with-space-separated-values
  selected=$(fc -rl 1 |
    perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="$fzf_default_opts" $(__fzfcmd))

  ret=$?

  if [ -n "$selected" ]; then
    # If the command doesn't have any arguments
    if (( ${#${=selected}} == 2 )); then
      BUFFER=$LBUFFER${${(z)selected}:1}$RBUFFER
      CURSOR=$(( $#LBUFFER + $#selected ))
    # If the command has at least one argument
    elif (( ${#${=selected}} > 2 )); then
      zle reset-prompt
      selected=$(printf '%s\n' "${${(z)selected}:1}" ${${${(z)selected}:2}//'\\n'} |
        FZF_DEFAULT_OPTS="$fzf_default_opts" $(__fzfcmd))

      ret=$?

      if [ -n "$selected" ]; then
        BUFFER=$LBUFFER${${selected//$'\n'/ }//\\n/$'\n'}$RBUFFER
        CURSOR=$(( $#LBUFFER + $#selected ))
      fi
    fi
  fi

  zle reset-prompt

  return $ret
} # }}}
zle -N fzf-history-widget
#########################################################

