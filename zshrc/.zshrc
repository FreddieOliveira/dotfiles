#########################################################
#            GLOBAL ENVIRONMENT VARIABLES               #
#########################################################
export PATH="$HOME/.local/bin:/opt/flutter/bin:/opt/android_sdk/platform-tools:/opt/android_sdk/tools:/opt/android_sdk/tools/bin:/opt/android_sdk/build-tools/28.0.3:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export MANPATH="/usr/local/man:$MANPATH"
export EDITOR='nvim'
export TERM='tmux-256color'
export ANDROID_HOME='/opt/android_sdk'


#########################################################
#              GLOBAL OH-MY-ZSH SETTINGS                #
#########################################################
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"


#########################################################
#                  THEME DEFINITION                     #
#########################################################
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel9k/powerlevel9k"


#########################################################
#              POWERLEVEL9K THEME SETTINGS              #
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
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders


#########################################################
#         ZSH-AUTOSUGGESTIONS PLUGIN SETTINGS           #
#########################################################
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


#########################################################
#                TMUX PLUGIN SETTINGS                   #
#########################################################
# autostart tmux server when starting the terminal
ZSH_TMUX_AUTOSTART="true" 

# don't close the terminal when killing tmux server
ZSH_TMUX_AUTOQUIT="false"


#########################################################
#                       PLUGINS                         #
#########################################################
# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    zsh-autosuggestions # suggests commands as typing based on history
    zsh-syntax-highlighting # colorize the current command according to its correctness
    tmux # define some alias to tmux commands
    fasd # enable fasd if its installed
    fzf # enable fzf if its installed
)


#########################################################
#                   OH-MY-ZSH LOADER                    #
#########################################################
# this will load the theme and plugins
source $ZSH/oh-my-zsh.sh


#########################################################
#                   ALIAS DEFINITIONS                   #
#########################################################
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if ! which pbcopy >/dev/null; then
    if which xclip >/dev/null; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    elif which xsel >/dev/null; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi
fi

alias lsblk='lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINT,SIZE,FSSIZE,FSUSED,FSAVAIL,FSUSE%,UUID,LABEL'

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# make F1-F12 keys to work inside htop
alias htop='TERM=linux htop'

#########################################################
#                   GENERAL CONFIGS                     #
#########################################################
# enable jedi shortcuts
setopt extendedglob

# git diff using vim
git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global alias.d difftool


#########################################################
#                    CUSTOM PLUGINS                     #
#########################################################
# these plugins are sourced at the end instead of inside
# the plugin variable, because the theme, which is sourced
# later, may mess with them. Also, their order is important:
# the vi-mode.plugin.zsh must be the first one
test -e "$ZSH/custom/plugins/vi-mode/vi-mode.plugin.zsh" && \
    source "$ZSH/custom/plugins/vi-mode/vi-mode.plugin.zsh"
test -e "$ZSH/custom/plugins/keybindings/keybindings.plugin.zsh" && \
    source "$ZSH/custom/plugins/keybindings/keybindings.plugin.zsh"
