#            GLOBAL ENVIRONMENT VARIABLES {{{1
#########################################################
export DISPLAY=:1
export EDITOR='nvim'
export PATH="$HOME/.local/bin:$PATH"
export TERM='tmux-256color'
export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_OPTS="--height=75% --tiebreak=begin --preview-window=down:80%:wrap:hidden --cycle --preview='preview.sh {}' --bind=ctrl-space:toggle-preview --keep-right"
# export MANPATH="/usr/local/man:$MANPATH"
# export LC_ALL='pt_BR.UTF-8'
# export LANG='pt_BR.UTF-8'
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
POWERLEVEL9K_BACKGROUND_JOBS_ICON='\uF013'  # 
POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_STATUS_OK_BACKGROUND="black"
POWERLEVEL9K_STATUS_OK_FOREGROUND="green"
POWERLEVEL9K_STATUS_ERROR_BACKGROUND="black"
POWERLEVEL9K_STATUS_ERROR_FOREGROUND="red"
POWERLEVEL9K_STATUS_LEFT_LEFT_WHITESPACE=''
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="black"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="yellow"
POWERLEVEL9K_TIME_ICON='\uF017'  # 
POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
POWERLEVEL9K_COMMAND_EXECUTION_TIME_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='\u256D'  # ╭
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status background_jobs root_indicator dir)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vcs time command_execution_time)
POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
POWERLEVEL9K_PROMPT_ON_NEWLINE="true"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
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
    --preview=$extract";preview.sh \$realpath"
# prevent populating fzf query. See https://github.com/Aloxaf/fzf-tab/issues/99
#zstyle ':fzf-tab:*' query-string prefix first
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
if which dircolors >/dev/null; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

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

# widget to copy selection to system clipboard
# use it by selecting a region while in vim visual mode,
# press : to enter execute mode and type cp_clipbrd_widget
function cp_clipbrd_widget() {
    local start_pos end_pos

    if ! which cp-clipbrd >/dev/null || [[ -z $CURSOR ]]; then
        return 1
    fi

    # if not in visual mode copy only the current char
    if (( ${REGION_ACTIVE:-0} == 0 )); then
        start_pos=end_pos=$CURSOR
    elif (( $CURSOR > $MARK )); then
        start_pos=$MARK
        end_pos=$CURSOR
    else
        start_pos=$CURSOR
        end_pos=$MARK
    fi

    # if in visual line mode, find the start and end of first and last lines
    if (( ${REGION_ACTIVE:-0} == 2 )); then
        local regex

        # start of first line
        regex='.*'$'\n'
        if [[ ${BUFFER:0:$start_pos} =~ $regex ]]; then
            start_pos=$(( MEND ))
        fi

        # end of last line
        regex='[^'$'\n]*'
        if [[ ${BUFFER:$end_pos} =~ $regex ]];then
            end_pos=$(( end_pos + MEND - 1 ))
        fi
    fi

    # copy the selection using the clipboard program aliased above
    printf $BUFFER[$(( start_pos + 1 )),$(( end_pos + 1 ))] | cp-clipbrd
}
zle -N cp_clipbrd_widget

alias lsblk='lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINT,SIZE,FSSIZE,FSUSED,FSAVAIL,FSUSE%,UUID,LABEL'

# make F1-F12 keys work inside htop
alias htop='TERM=linux htop'

# useful apt commands with fzf
alias add="apt-cache search . | cut -d' ' -f1 | fzf --layout=reverse -m --cycle --height=65% --preview-window=down:75%:wrap:hidden --preview='apt show {} 2>/dev/null; dpkg-query -L {} 2>&1 | sort | tail -n +2 | while read cur; do [[ \$cur != \$prev/* ]] && echo \$prev; prev=\$cur; done; echo \$prev;' | xargs -ro pkg install"
alias del="dpkg-query --no-pager -W -f='\${binary:Package}\n' | cut -d' ' -f1 | fzf --layout=reverse -m --cycle --height=65% --preview-window=down:75%:wrap:hidden --preview='apt show {} 2>/dev/null; dpkg-query -L {} | sort | tail -n +2 | while read cur; do [[ \$cur != \$prev/* ]] && echo \$prev; prev=\$cur; done; echo \$prev;' | xargs -ro apt purge"
#########################################################
#                   GENERAL CONFIGS {{{1
#########################################################
# enable jedi shortcuts
setopt extendedglob

# git diff using vim
git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global alias.d difftool

# fzf-tab config that must be set at the end
zstyle ':completion:*:descriptions' format '[%d]' # enable group support
#########################################################
