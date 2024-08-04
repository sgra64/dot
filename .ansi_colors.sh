# ANSI color definitions and control
# https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
# https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt
# 
declare -gA ANSI_COLORS=(
    # ["dimmed-red"]="\e[2;31m" or "\033[2;31m"
    ["black"]="1;30"
    ["dimmed-grey"]="2;30"  ["dimmed-red"]="2;31"   ["dimmed-green"]="2;32"
    ["dimmed-yellow"]="2;33" ["dimmed-blue"]="2;34" ["dimmed-purple"]="2;35"
    ["dimmed-cyan"]="2;36"  ["dimmed-white"]="2;37"

    ["grey"]="1;30"         ["red"]="1;31"          ["green"]="1;32"
    ["yellow"]="1;33"       ["blue"]="1;34"         ["purple"]="1;35"
    ["cyan"]="1;36"         ["white"]="1;37"

    ["low-grey"]="0;30"     ["low-red"]="0;31"      ["low-green"]="0;32"
    ["low-yellow"]="0;33"   ["low-blue"]="0;34"     ["low-purple"]="0;35"
    ["low-cyan"]="0;36"     ["low-white"]="0;37"    # ["low-white"]="0;37;1"

    ["bright-grey"]="1;90"  ["bright-red"]="1;91"   ["bright-green"]="1;92"
    ["bright-yellow"]="1;93" ["bright-blue"]="1;94" ["bright-purple"]="1;95"
    ["bright-cyan"]="1;96"  # turquoise
    ["bright-white"]="1;97" # boldish bright white
    ["light-red-bg"]="1;101"

    ["reset"]="\e[" # or "\033["
    ["0"]="0"
)

function prompt() {
    [ "$1" = "color" ] && local skip=1 && local s=0
    [ "$1" = "mono" ] && local skip=3 && local s=0
    local e=""
    for k in "$@"; do
        [ "$s" = "1" ] && e+="\e[${ANSI_COLORS[$k]}m" && s=2 && continue
        [ "$s" = "2" ] && e+="$k" && s=$skip && continue
        [ "$s" = "3" ] && s=2
        [ "$s" = "0" ] && s=$skip
    done; printf $e
}

function color {
    #
    function ls_colors() {
        local s=0; local e=""
        for k in "$@"; do
            [ "$s" = "1" ] && e+="${ANSI_COLORS[$k]}" && s=2
            [ "$s" = "0" ] && e+="$k=" && s=1
            [ "$s" = "2" ] && e+=":" && s=0
        done; printf $e
    }
    # 
    # Only enable color when terminal supports colors. Test with $(tput colors),
    # see: https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
    if [ "$1" = "on" -a $(tput colors) ]; then
        export TERM="xterm-256color"
        #
        # Set coloring scheme for 'ls' command (with --color=auto)
        # https://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
        # - di: directory
        # - fi: file
        # - ow: directory that is other-writable (o+w) and not sticky
        # - ln: symbolic link
        # - ex: executable file
        # 
        # export LS_COLORS="di=1;36:ln=1;31:fi=36:ex=36:*.tar=1;37"
        # export LS_COLORS="di=1;97:ow=1;37:ln=1;34:fi=0;37:ex=0;31:*.tar=0;36:*.jar=0;36"
        # 
        export LS_COLORS=$(ls_colors \
            "di"    bright-white \
            "ow"    white \
            "fi"    low-white \
            "ex"    dimmed-red \
            "ln"    blue \
            "*.tar" low-cyan \
            "*.jar" low-cyan \
        )
        aliases color
        PS1=$(prompt color ${PROMPT[@]})
        trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
    fi
    # 
    if [ "$1" = "off" -o ! $(tput colors) ]; then
        export TERM="dumb"  # "term-mono" does not disable vim colors, "dumb" does
        export LS_COLORS=$(ls_colors \
            "rs" 0 "di" 0 "ln" 0 "mh" 0 "pi" 0 "so" 0 "do" 0 "bd" 0 \
            "cd" 0 "or" 0 "mi" 0 "su" 0 "sg" 0 "ca" 0 "tw" 0 "ow" 0 \
            "st" 0 "ex" 0 \
        )
        aliases mono
        PS1=$(prompt mono ${PROMPT[@]})
        trap "" DEBUG
    fi
}

function show_colors() {
    # 
    function CLR() {
        for k in "$@"; do
            local col=${ANSI_COLORS[$k]}
            [ "$col" ] && printf "\e["${col}"m" || printf "%s" "$k"
        done
    }
    echo "yellow:" $(CLR reset dimmed-yellow "##" low-yellow "##" bright-yellow "##" reset "##")
    echo "red:   " $(CLR reset dimmed-red "##" low-red "##" bright-red "##" reset "##")
    echo "purple:" $(CLR reset dimmed-purple "##" low-purple "##" bright-purple "##" reset "##")
    echo "blue:  " $(CLR reset dimmed-blue "##" low-blue "##" bright-blue "##" reset "##")
    echo "cyan:  " $(CLR reset dimmed-cyan "##" low-cyan "##" bright-cyan "##" reset "##")
    echo "green: " $(CLR reset dimmed-green "##" low-green "##" bright-green "##" reset "##")
    echo
    # 
    for i in "dimmed-" "low-" "" "bright-"; do
        for j in grey red green yellow blue purple cyan white; do
            printf $(CLR $i$j "xx")
        done
        echo
    done
}

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
