#            GLOBAL ENVIRONMENT VARIABLES {{{1
#########################################################
export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
# export MANPATH="/usr/local/man:$MANPATH"
export EDITOR='nvim'
export TERM='tmux-256color'
export FZF_DEFAULT_OPTS="--height=75% --tiebreak=begin --preview-window=down:80%:wrap:hidden --preview='bat --style=numbers --color=always --line-range=:200 {}' --bind=space:toggle-preview --keep-right"
#########################################################
#              GLOBAL OH-MY-ZSH SETTINGS {{{1
#########################################################
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
#########################################################
#                  THEME DEFINITION {{{1
#########################################################
ZSH_THEME="powerlevel10k/powerlevel10k"
#########################################################
#                   THEME SETTINGS {{{1
#########################################################
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_NODE_VERSION_BACKGROUND='28'
POWERLEVEL9K_NODE_VERSION_FOREGROUND='15'
POWERLEVEL9K_BACKGROUND_JOBS_ICON="\U1F634  "
POWERLEVEL9K_VCS_STAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_UNTRACKED_ICON='\u25CF'
POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_STATUS_OK_BACKGROUND="black"
POWERLEVEL9K_STATUS_OK_FOREGROUND="green"
POWERLEVEL9K_STATUS_ERROR_BACKGROUND="black"
POWERLEVEL9K_STATUS_ERROR_FOREGROUND="red"
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time status background_jobs root_indicator context dir)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vcs time)
POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
POWERLEVEL9K_PROMPT_ON_NEWLINE="true"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER="true"
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders
POWERLEVEL9K_LEGACY_ICON_SPACING="true"
ZLE_RPROMPT_INDENT=0
#########################################################
#                   PLUGINS SETTINGS {{{1
#########################################################
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
#>----| zfz-tab {{{2
################################
# fix window preview. See https://github.com/Aloxaf/fzf-tab/issues/77
local extract="
# trim input
local in=\${\${\"\$(<{f})\"%\$'\0'*}#*\$'\0'}
# get ctxt for current completion
local -A ctxt=(\"\${(@ps:\2:)CTXT}\")
# real path
local realpath=\$(eval echo \${ctxt[IPREFIX]}\${ctxt[hpre]}\$in)
"
zstyle ':fzf-tab:complete:*:*' extra-opts \
    --preview=$extract";preview.zsh \$realpath"
# prevent populating fzf query. See https://github.com/Aloxaf/fzf-tab/issues/99
zstyle ':fzf-tab:*' query-string prefix first
################################
#>----| tmux {{{2
################################
# autostart tmux server when starting the terminal
ZSH_TMUX_AUTOSTART="true" 
# don't close the terminal when killing tmux server
ZSH_TMUX_AUTOQUIT="false"
#########################################################
#                  PLUGINS SELECTION {{{1
#########################################################
# add wisely, as too many plugins slow down shell startup
# also, be aware of the plugins order, as one may interfer with others
plugins=(
    tmux # define some tmux commands aliases
    fasd # enable fasd if its installed
    vi-mode # be sure to put this before fzf
    fzf-tab # be sure to put this before fzf
    fzf # enable fzf if its installed
    zsh-autosuggestions # suggests commands as typing based on history
    #zsh-syntax-highlighting # colorize the current command according to its correctness
    fast-syntax-highlighting # add real time syntax highlighting
)
#########################################################
#                   OH-MY-ZSH LOADER {{{1
#########################################################
# this will load the theme and plugins
source $ZSH/oh-my-zsh.sh
#########################################################
#                   ALIASES DEFINITIONS {{{1
#########################################################
# colorful ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# clipboard copy and paste
if ! which pbcopy >/dev/null; then
    if which xclip >/dev/null; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    elif which xsel >/dev/null; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    else
        if which termux-clipboard-set >/dev/null; then
            alias pbcopy='termux-clipboard-set'
        fi
        if which termux-clipboard-get >/dev/null; then
            alias pbpaste='termux-clipboard-get'
        fi
    fi
fi

alias lsblk='lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINT,SIZE,FSSIZE,FSUSED,FSAVAIL,FSUSE%,UUID,LABEL'

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# make F1-F12 keys work inside htop
alias htop='TERM=linux htop'
#########################################################
#                   GENERAL CONFIGS {{{1
#########################################################
# enable jedi shortcuts
setopt extendedglob

# git diff using vim
git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global alias.d difftool
#########################################################
