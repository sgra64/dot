# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .profile:
# - SYS: Win:CYGWIN, Win:MINGW, Win:ZSH, WSL:Ubuntu, Linux
# - PATH: path
# - HOSTNAME_ALIAS: alias name for system hostname, e.g. 'X1' for 'LAPTOP-V50CGD0T'
# - HAS_GIT: true, false
# - ZSH: set in zsh
# - ENV_SH: source this file when entering directory of a git project, e.g. '.env.sh'
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
# .git-cd.sh
# - GIT_PROJECT: 
# - GIT_PATH: 
# - cd()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo ".bashrc"

type shopt &>/dev/null && if [[ $? ]]; then
    # check window size after each command and update values of LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite it
    shopt -s histappend
fi
# don't put duplicate lines or lines with whitespaces in history
# https://www.baeldung.com/linux/history-remove-avoid-duplicates
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=999
export HISTFILESIZE=999

# source PATH variable from ~/.pathrc file for Windows environment
[ -f ~/.path_rc ] && [[ "$SYS" =~ Win:. ]] && \
    builtin source ~/.path_rc

# source color control functions for ANSI terminals
[ -f ~/.ansi-colors.sh ] && \
    builtin source ~/.ansi-colors.sh

[ -z "$TERM_HAS_COLORS" ] && \
    export TERM_HAS_COLORS=$([[ "$(tput colors)" -gt 1 ]] && \
        [ "$(typeset -f ansi_code)" ] && \
        echo true || echo false)

# overlay 'cd' command for PS1 prompt used within git projects,
# defines variables GIT_PROJECT with the name of git project and
# GIT_PATH with the path of git project
[ "$HAS_GIT" = true ] && \
    function cd() {
        local prior_value_of_GIT_PROJECT=$GIT_PROJECT
        # 
        [ "$1" ] && local cd_path=$1 && shift || local cd_path=$HOME
        # 
        # actually change directory
        builtin cd "$cd_path" $*
        # 
        export PWD=$(realpath . )   # set '\w' in PS1 prompt string
        local git_project=""
        local dir=$PWD
        # 
        while [ "$dir" != "/" -a "$dir" != "$HOME" ]; do
            [ -d "$dir/.git" ] && \
                git_project=$(basename "$dir") && \
                break
            dir=$(dirname "$dir")
        done
        # 
        [ "$git_project" ] && \
            local path=$(pwd) && \
            export GIT_PATH=${path/"$dir"/\.} || unset GIT_PATH
        # 
        # rebuild PS1 using the prompt function
        export GIT_PROJECT=$git_project
        prompt

        # test git-project was entered for the first time
        if [ -z "$prior_value_of_GIT_PROJECT" -a "$GIT_PROJECT" -a "$ENV_SH" ]; then
            # sourcing when $GIT_PROJECT is entered
            echo "entering GIT_PROJECT: $dir"
            [ -f "$dir"/$ENV_SH ] && builtin source "$dir"/$ENV_SH "$GIT_PROJECT" "$dir"
        fi
        # 
        if [ "$prior_value_of_GIT_PROJECT" -a -z "$GIT_PROJECT" ]; then
            # echo "leaving GIT_PROJECT: $prior_value_of_GIT_PROJECT"
            # invoke 'leave()' function if set by project environment
            [ "$(typeset -f leave)" ] && leave "$prior_value_of_GIT_PROJECT" "$dir"
            unset prior_value_of_GIT_PROJECT
        fi
    }

function aliases() {
    [ "$1" = "color" ] && local color="--color=auto" || local mvn_mono="-B"
    # 
    alias c="clear"
    alias vi="vim"              # use vim for vi, -u ~/.vimrc
    alias ls="/bin/ls $color"   # colorize ls output
    alias l="ls -alFog"         # detailed list with dotfiles
    alias ll="ls -l"            # detailed list with no dotfiles
    alias grep="grep $color"
    alias egrep="egrep $color"
    alias pwd="pwd -LP"         # show real path with resolved links
    alias path="echo \$PATH | tr ':' '\012'"
    [ "$MAVEN_HOME" ] && \
        alias mvn="$MAVEN_HOME/bin/mvn $mvn_mono"   # -B: color off
    # 
    # set useful git aliases
    #  - prune, https://stackoverflow.com/questions/2116778/reduce-git-repository-size
    [ "$HAS_GIT" = true ] && \
        alias gt="git status" && \
        alias switch="git switch" && \
        alias log="git log --oneline" && \
        alias br="git branch -avv" && \
        alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" && \
        alias gar="[ -d .git ] && tar cvf $(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'"

    function source() { # source dotfile depending on $1 and location
        if [ -z "$1" ]; then
            [ -f "$ENV_SH" ] && local dotfile="$ENV_SH" || local dotfile="$HOME/.bashrc"
        else
            local dotfile="$1"
        fi
        echo "sourcing: $dotfile"; builtin source "$dotfile"
    }
    function rp() {     # show realpath of $1
        [ "$1" ] && realpath $* || realpath .
    }
    function h() {      # list history commands, select by $1
        [ "$1" == "--all" ] && history | uniq -f 1 && return
        [ "$1" ] && history | grep $1 | uniq -f 1 || history | tail -40
    }
    function functions() {  # list functions by name or specific function
        local fname="$1"
        [ "$fname" ] && typeset -f $fname || declare -F
    }
    function crlf() {   # list text files with CR/LF (Windows) line endings
        [ "$1" ] && local dir="$*" || local dir="."
        find "$dir" -not -type d -exec file "{}" ";" | grep CRLF | cut -d: -f1
    }
    function cr2lf() {  # replace CR/LF (Windows) with newline (Unix) line endings
        for f in $(crlf "$*"); do
            echo "-- converting CRLF to '\n' in --> $f"
            tmpfile="/tmp/$(basename "$f")"
            sed 's/\r$//' < "$f" > "$tmpfile"
            mv "$tmpfile" "$f"
        done
    }
}

function prompt() {
    # 
    if [ -z "$GIT_PROJECT" ]; then
        # no $GIT_PROJECT variable set means regular prompt (not inside git project)
        # GNU prompt control sequences for PS1 variable
        # https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
        # PS1='\[\e[32m\]\u@\h:\W> \[\e[0m\]'
        local regular_prompt=(
            white       '\\\\\\\n'
            green       '\! '           # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME_ALIAS\047 '   # \u user, \h hostname
            # low-white   '($(date "+%H:%M")) '
            low-white   '(\D{%H:%M}) '
            yellow      '\w '           # \w path relative to $HOME, \W only dirname
            reset       '\012'          # \012 newline
            white       # color for typed command
        )
        PS1=$(colorize_prompt "$PROMPT_COLOR" "${regular_prompt[@]}")
    # 
    else
        # prompt inside git project
        local git_prompt=(
            white       '\\\\\\\n'
            green       '\! '           # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME_ALIAS\047 '   # \u user, \h hostname
            blue        "$GIT_PROJECT "
            white       '['
            # purple      '$(git branch --show-current)'    # not working on Ubuntu
            purple      '$(git symbolic-ref --short HEAD 2>/dev/null)'
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
    [ "$1" = "on" ] && color true && return
    [ "$1" = "off" ] && color false && return
    # 
    if [ "$1" = true ] && [ "$TERM_HAS_COLORS" = true ]; then
        # 
        # vim coloring requires "xterm-256color"
        export TERM="xterm-256color"
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
            "*.zip" low-cyan \
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
        aliases color

        [ "$HAS_GIT" = true ] && \
            $(git config color.ui true 2>/dev/null)

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
            $(git config color.ui false 2>/dev/null)

        export PROMPT_COLOR=false
        prompt
    fi
}

if [[ ! "$SYS" =~ .*ZSH ]]; then
    [ "$PROMPT_COLOR" ] && \
        color $PROMPT_COLOR || color $TERM_HAS_COLORS
else
    # zsh only set aliases, but no color or prompt
    aliases
fi

# cd to start directory, if passed as START_DIR environment variable
# when shell is started in arbitrary directory, e.g. from context menu
[ "$START_DIR" ] && \
    cd "$START_DIR"

unset START_DIR      # remove start directory
