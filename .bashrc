# /etc/bash.bashrc has run before
[ "$LOG" ] && echo .bashrc $1

# test works for bash and zsh
type shopt &>/dev/null && if [[ $? ]]; then
    # check window size after each command and update values of LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite it
    shopt -s histappend
fi
# don't put duplicate lines or lines with whitespaces in history
HISTCONTROL=ignoreboth
HISTSIZE=999
HISTFILESIZE=999

function aliases() {
    local color=$([ "$1" = "color" ] && echo "--color=auto")
    alias h="history "
    # alias l="ls -alFog --color=auto "
    # alias ls="ls -A --color=auto "
    # alias grep="grep --color=auto"
    # alias fgrep="fgrep --color=auto"
    # alias egrep="egrep --color=auto"

    alias l="ls -alFog $color "
    alias ls="ls -A $color "
    alias grep="grep $color"
    alias fgrep="fgrep $color"
    alias egrep="egrep $color"

    alias pwd="pwd -LP"     # show real path with resolved links
    alias path="echo \$PATH | tr ':' '\012'"
    alias gt="git status"

    function rp() {
        realpath $([ -z "$1" ] && echo . || echo $*)
    }
}

case "$1" in
    # 
    Win:CYGWIN|Win:MINGW|Win:ZSH)
        # append PATH (PATH+=does not work with zsh)
        export PATH="${PATH}:/c/Program Files (x86)/Git/cmd"
        export PATH="${PATH}:/c/Users/svgr2/AppData/Local/Programs/Microsoft VS Code/bin"
        # 
        # leave .bashrc if called from .zshrc with 'source .bashrc Win:ZSH'
        # [[ "$1" = "Win:ZSH" ]] && return
        ;;
    # 
    WSL:*)
        ;;
esac


# date '+%H:%M'
# set a default prompt of: user@host and current_directory (adjusted from /etc/bash.bashrc)
# PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
# PS1='\[\e]0;\w\a\]\\\\\\\\\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
# 
PROMPT=(
    white   '\\\\\\\\\\\\\\\\\n'
    low-green       "\\\u@\h "
    yellow          "\w "
    white           "$ "
    bright-white
)

function enable() {
    aliases mono
    PS1='\\\\\\\n\u@\h \w $ '
}

[ -f ~/.ansi_colors.sh ] && \
    source ~/.ansi_colors.sh && \
    color on || enable


# remove functions and variables that are no longer needed
unset enable
