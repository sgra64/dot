function set_monochrome() {
    export COLOR="off";
    export TERM="dumb"     # "term-mono" does not disable vim colors, "dumb" does
    export LS_COLORS='rs=0:di=0:ln=0:mh=0:pi=0:so=0:do=0:bd=0:cd=0:or=0:mi=0:su=0:sg=0:ca=0:tw=0:ow=0:st=0:ex=0'
    # 
    # if set_prompt function exists, execute it or set default prompt
    [ "$( type set_prompt 2>/dev/null | grep 'function' )" ] \
        && set_prompt off || PS1="\u@\h $ "
}

function set_color() {
    # Only enable color when terminal supports colors. Test with $(tput colors),
    # see: https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
    if [ $(tput colors) ]; then
        export COLOR="on";
        export TERM="xterm-256color"
        # export LS_COLORS="di=1;36:ln=1;31:fi=36:ex=36:*.tar=1;37"
        export LS_COLORS="di=1;37:ow=1;37:ln=1;34:fi=0;37:ex=0;31:*.tar=0;36:*.jar=0;36"
        # 
        # if set_prompt function exists, execute it or set default prompt
        [ "$( type set_prompt 2>/dev/null | grep 'function' )" ] \
            && set_prompt on || PS1="\u@\h $ "
    else
        set_monochrome
    fi
}

# command to turn: color <on|off>
function color() {
    local next=$( echo $1 | tr 'A-Z' 'a-z' | egrep -e '(on|off)' )
    local state=$( [ $(echo $COLOR | egrep -e '(on|off)' ) ] && echo $COLOR || \
                    ( [ -z "$COLOR" ] && echo "init" || echo "illegal" ) )
    # simple state machine: <s> -> <init> -> (<on> <-> <off>)
    case "$state:$next" in
        init:on) set_color "init" ;;
        init:off) set_monochrome "init" ;;
        off:on) set_color ;;
        on:off) set_monochrome ;;
        # no state change, needed to trigger set functions when $COLOR is inherited
        on:on) set_color ;;             # 
        off:off) set_monochrome ;;
        # any other 'next' argument
        on:*|off:*) echo "color is $COLOR" ;;
        # init:*) set_monochrome "init" ;;
    esac
}

# see ANSI color definitions
# https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
# https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt
# 
declare -gA COLORS=(
    # ["dimmed-red"]="\e[2;31m" or "\033[2;31m"
    ["black"]="1;30"
    ["dimmed-grey"]="2;30"
    ["dimmed-red"]="2;31"
    ["dimmed-green"]="2;32"
    ["dimmed-yellow"]="2;33"
    ["dimmed-blue"]="2;34"
    ["dimmed-purple"]="2;35"
    ["dimmed-cyan"]="2;36"
    ["dimmed-white"]="2;37"

    ["grey"]="1;30"
    ["red"]="1;31"
    ["green"]="1;32"
    ["yellow"]="1;33"
    ["blue"]="1;34"
    ["purple"]="1;35"
    ["cyan"]="1;36"
    ["white"]="1;37"

    ["low-grey"]="0;30"
    ["low-red"]="0;31"
    ["low-green"]="0;32"
    ["low-yellow"]="0;33"
    ["low-blue"]="0;34"
    ["low-purple"]="0;35"
    ["low-cyan"]="0;36"
    ["low-white"]="0;37"
    # ["low-white"]="0;37;1"

    ["bright-grey"]="1;90"
    ["bright-red"]="1;91"
    ["bright-green"]="1;92"
    ["bright-yellow"]="1;93"
    ["bright-blue"]="1;94"
    ["bright-purple"]="1;95"
    ["bright-cyan"]="1;96"      # turquoise
    ["bright-white"]="1;97"     # boldish bright white
    ["light-red-bg"]="1;101"
    ["reset"]="\e["             # or "\033["
)

# Put the cursor at line L and column C \033[<L>;<C>H
# Put the cursor at line L and column C \033[<L>;<C>f
# Move the cursor up N lines            \033[<N>A
# Move the cursor down N lines          \033[<N>B
# Move the cursor forward N columns     \033[<N>C
# Move the cursor backward N columns    \033[<N>D
# Clear the screen, move to (0,0)       \033[2J
# Erase to end of line                  \033[K
# Save cursor position                  \033[s
# Restore cursor position               \033[u
