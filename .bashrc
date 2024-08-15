# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .profile:
# - LOG: true, false
# - SYS: Win:CYGWIN, Win:MINGW, Win:ZSH, WSL:Ubuntu, Linux
# - PATH: path
# - HOSTNAME_ALIAS: alias name for system hostname, e.g. 'X1' for 'LAPTOP-V50CGD0T'
# - HAS_GIT: true, false
# - ZSH: set in zsh
# 
# .bashrc:
# - TERM_HAS_COLORS: true, false
# - TERM: xterm-direct, xterm-256color, xterm-mono, dumb
# - LS_COLORS: 
# - PROMPT_COLOR: color, mono
# 
# - aliases()
# - prompt()
# - color(): on, off, true, false
# 
# .env-windows.sh
# - USER, USERNAME, HOME, PWD, PATH
# - env_Windows()
# 
# .ansi-colors.sh
# - ansi_code(), colorize_prompt(), colorize_ls_colors()
# 
# .git-prompt.sh
# - GIT_PROJECT: 
# - GIT_PATH: 
# - cd()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# /etc/bash.bashrc has run before
[ "$LOG" = true ] && echo ".bashrc"

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

[ "$HAS_GIT" = true ] && [ -f ~/.git-prompt.sh ] && \
    source ~/.git-prompt.sh

# source color control functions for ANSI terminals
[ -f ~/.ansi-colors.sh ] && \
    source ~/.ansi-colors.sh

[ -z "$TERM_HAS_COLORS" ] && \
    export TERM_HAS_COLORS=$([[ "$(tput colors)" -gt "1" ]] && \
        [ "$(typeset -f ansi_code)" ] && \
        echo true || echo false)


function aliases() {
    local color=$([ "$1" = "color" ] && echo "--color=auto")
    # 
    alias c="clear "
    # example: alias ls="ls -A --color=auto "
    alias ls="/bin/ls $color "  # colorize ls output
    alias l="ls -alFog "        # detailed list with dotfiles
    alias ll="ls -l "           # detailed list with no dotfiles
    alias grep="grep $color "
    alias fgrep="fgrep $color "
    alias egrep="egrep $color "
    alias pwd="pwd -LP "        # show real path with resolved links
    alias path="echo \$PATH | tr ':' '\012'"
    # 
    alias gt="git status"

    function rp() {
        realpath $([ -z "$1" ] && echo . || echo $*)
    }
    function h() {
        [ "$1" == "-all" ] && history && return
        [ "$1" ] && history | grep $1 || history | tail -40
    }
}

function prompt() {
    # 
    if [ -z "$GIT_PROJECT" ]; then
        # no $GIT_PROJECT variable set means regular prompt (not inside git project)
        # GNU prompt control sequences for PS1 variable
        # https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
        # PS1='\[\e[32m\]\u@\h:\W> \[\e[0m\]'
        local reg_prompt=(
            white       '\\\\\\\n'
            green       '\! '           # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME_ALIAS\047 '   # \u user, \h hostname
            # low-white   '($(date "+%H:%M")) '
            low-white   '(\D{%H:%M}) '
            yellow      '\w '           # \w path relative to $HOME, \W only dirname
            reset       '\012'          # \012 newline
            white       # color for typed command
        )
        PS1=$(colorize_prompt "$PROMPT_COLOR" "${reg_prompt[@]}")
    # 
    else
        # prompt inside git project
        local git_prompt=(
            white       '\\\\\\\n'
            green       '\! '           # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME_ALIAS\047 '   # \u user, \h hostname
            blue        "$GIT_PROJECT "
            white       '['
            purple      '$(git branch --show-current)'
            white       '] '
            yellow      "$GIT_PATH"
            reset       '\012'          # \012 newline
            white       # color for typed command
        )
        PS1=$(colorize_prompt "$PROMPT_COLOR" "${git_prompt[@]}")
    fi
    # 
    if [ "$PROMPT_COLOR" = true ]; then
        trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
    else
        trap "" DEBUG
    fi
}

function color() {
    # [ "$1" = "color" ] && color true && return
    # [ "$1" = "mono" ] && color false && return
    [ "$1" = "on" ] && color true && return
    [ "$1" = "off" ] && color false && return
    # 
    if [ "$1" = true ] && [ "$TERM_HAS_COLORS" = true ]; then
        # 
        export TERM="xterm-direct"      # default terminal (ANSI colors)
        # export TERM="xterm-256color"
        #
        # Set coloring scheme for 'ls' command (with --color=auto)
        # https://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
        # - di: directory
        # - fi: file
        # - ow: directory that is other-writable (o+w) and not sticky
        # - ln: symbolic link
        # - or: orphan, broken symbolic link
        # - mi: missing file for symbolic link
        # - ex: executable file
        # 
        # export LS_COLORS="di=1;36:ln=1;31:fi=36:ex=36:*.tar=1;37"
        # export LS_COLORS="di=1;97:ow=1;37:ln=1;34:fi=0;37:ex=0;31:*.tar=0;36:*.jar=0;36"
        # 
        # set dircolors database, show with `dircolors --print-database` command
        export LS_COLORS=$(colorize_ls_colors \
            "di"    bright-white \
            "ow"    white \
            "fi"    low-white \
            "ex"    red \
            "ln"    blue \
            "or"    blue \
            "mi"    broken-link \
            "*.tar" low-cyan \
            "*.jar" low-cyan \
        )
        case "$SYS" in
            # overwrite LS_COLORS for WSL:Ubuntu with:
            # - ex: red -> low-white (WSL:Ubuntu shows all files as executable),
            # - ln, or: blue -> cyan
            WSL:Ubuntu) export LS_COLORS+=":"$(colorize_ls_colors \
                "ex"    low-white \
                "ln"    cyan \
                "or"    cyan \
            ) ;;
        esac
        # 
        aliases color

        [ "$HAS_GIT" = true ] && \
            git config color.ui true
        # 
        export PROMPT_COLOR=true
        prompt
    # 
    else
        export TERM="xterm-mono"
        # export TERM="dumb"    # alternative: "dumb" to disable colors in vi
        # 
        export LS_COLORS=$(colorize_ls_colors \
            "rs" 0 "di" 0 "ln" 0 "mh" 0 "pi" 0 "so" 0 "do" 0 "bd" 0 \
            "cd" 0 "or" 0 "mi" 0 "su" 0 "sg" 0 "ca" 0 "tw" 0 "ow" 0 \
            "st" 0 "ex" 0 \
        )
        aliases mono
        [ "$HAS_GIT" = true ] && \
            git config color.ui false
        # 
        export PROMPT_COLOR=false
        prompt
    fi
}

[ "$PROMPT_COLOR" ] && \
    color $PROMPT_COLOR || color $TERM_HAS_COLORS

# force cd overlay function to execute when new bash is launched
# cd .
# [[ "$SHLVL" -gt 1 ]] && cd .
