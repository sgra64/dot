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
    # 
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

    if [[ "$SYS" =~ WSL:.* ]]; then
        # Ubuntu merges dotfiles and regular files in directory listings
        # stackoverflow: "Sorting directory contents (including hidden files) by name"
        alias l="LC_ALL=C ls -lA --group-directories-first $color "
        alias ls="LC_ALL=C ls -lA --group-directories-first $color "
    fi

    alias pwd="pwd -LP"     # show real path with resolved links
    alias path="echo \$PATH | tr ':' '\012'"
    # 
    alias gt="git status"
    # alias gt="git $([ "$1" != "color" ] && echo "-c color.ui=false ")status"
    [ "$1" = "color" ] && git config color.ui true || git config color.ui false

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
        [[ "$1" = "Win:ZSH" ]] && return
        ;;
    # 
    WSL:*)
        ;;
esac

# date '+%H:%M'
PROMPT=(
    white   '\\\\\\\\\\\\\\\\\\\\\\\\\\\\n'
    low-green   '\\\\u@\h '
    yellow      '\w '
    reset       '$ '
    white       # color for typed command
)
PROMPT_MONO='\\\\\\\n\u@\h \w $ '

function default() {
    aliases mono
    PS1=$PROMPT_MONO
}

[ -f ~/.ansi_colors.sh ] && \
    source ~/.ansi_colors.sh && \
    color on || default

# remove functions and variables that are no longer needed
unset default
