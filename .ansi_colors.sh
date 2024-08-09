# ANSI colors and terminal control sequences
# - https://en.wikipedia.org/wiki/ANSI_escape_code
# - https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
# - https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt

declare -gA ANSI_COLORS=(
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

    ["broken-link"]="1;4;37;41" # used for broken links (white on red background)
)

function ansi_code() {
    local code=$1
    local text=$2
    local reset="\[\e[0m\]"     # alternatively: "\[\033[0m\]"
    # 
    case "$code" in
    "reset")    printf "$reset$text" ;;
    "0")        printf "0" ;;
    *)          local esc=${ANSI_COLORS[$code]}
                [ "$text" = "--unterminated" ] && text="" && reset=""
                [ "$esc" ] && printf "\[\e["$esc"m\]$text$reset" ;;
    esac
}

function build_prompt() {
    # problem: Cygwin bash prompt is wrapping lines on the same line
    # https://superuser.com/questions/283236/cygwin-bash-prompt-is-wrapping-lines-on-the-same-line
    # PS1='\[\e[32m\]\u@\h:\W> \[\e[0m\]'
    # 
    local s=0; local code=""; local e=""
    for k in "$@"; do
        [ "$s" = 0 -a "$k" = "mono" ] && s=10 && continue
        [ "$s" = 0 -a "$k" = "color" ] && s=20 && continue
        # 
        # mono prompt
        [ "$s" = 10 ] && s=11 && continue
        # [ "$s" = 11 ] && s=10 && e+="$k" && continue
        # [ "$s" = 11 ] && s=10 && e+=$(ansi_code "reset" "$k") && continue
        [ "$s" = 11 ] && s=10 && e+=$(echo "$k" | sed -e 's/\\//g') && continue
        # 
        # colored prompt
        [ "$s" = 20 ] && s=21 && code="$k" && continue
        [ "$s" = 21 ] && s=20 && \
            e+=$(ansi_code "$code" "$k") && \
            code="" && continue
    done;
    # append unterminated color code (no '\[\e[0m\]' after text) to
    # allow colored typing (commands)
    [ "$code" ] && e+=$(ansi_code "$code" "--unterminated")
    # 
    printf "$e"     # output sequence for PS1 (must quote "$e")
}

function color {
    local onoff=$1
    #
    function ls_colors() {
        local s=0; local e=""
        for k in "$@"; do
            [ "$s" = 1 ] && e+="${ANSI_COLORS[$k]}" && s=2
            [ "$s" = 0 ] && e+="$k=" && s=1
            [ "$s" = 2 ] && e+=":" && s=0
        done;
        printf "$e"     # output sequence for LS_COLORS (must quote "$e")
    }
    # 
    # Only enable color when terminal supports colors. Test with $(tput colors),
    # see: https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
    if [ "$onoff" = "on" ] && [ "$(tput colors)" ]; then
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
        export LS_COLORS=$(ls_colors \
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
        aliases color
        # 
        PS1=$(build_prompt color "${PROMPT[@]}")
        trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
    fi
    # 
    if [ "$onoff" = "off" ] || [ -z "$(tput colors)" ]; then
        export TERM="xterm-mono"    # alternative: "dumb" to disable colors in vi
        export LS_COLORS=$(ls_colors \
            "rs" 0 "di" 0 "ln" 0 "mh" 0 "pi" 0 "so" 0 "do" 0 "bd" 0 \
            "cd" 0 "or" 0 "mi" 0 "su" 0 "sg" 0 "ca" 0 "tw" 0 "ow" 0 \
            "st" 0 "ex" 0 \
        )
        aliases mono
        # 
        # PS1=$(build_prompt mono "${PROMPT[@]}")
        PS1=$PROMPT_MONO
        trap "" DEBUG
    fi
}

# function show_colors() {
#     # 
#     function CLR() {
#         for k in "$@"; do
#             local col=${ANSI_COLORS[$k]}
#             [ "$col" ] && printf "\[\e["${col}"m\]" || printf "%s" "$k"
#         done
#     }
#     echo "yellow:" $(CLR reset dimmed-yellow "##" low-yellow "##" bright-yellow "##" reset "##")
#     echo "red:   " $(CLR reset dimmed-red "##" low-red "##" bright-red "##" reset "##")
#     echo "purple:" $(CLR reset dimmed-purple "##" low-purple "##" bright-purple "##" reset "##")
#     echo "blue:  " $(CLR reset dimmed-blue "##" low-blue "##" bright-blue "##" reset "##")
#     echo "cyan:  " $(CLR reset dimmed-cyan "##" low-cyan "##" bright-cyan "##" reset "##")
#     echo "green: " $(CLR reset dimmed-green "##" low-green "##" bright-green "##" reset "##")
#     echo
#     # 
#     for i in "dimmed-" "low-" "" "bright-"; do
#         for j in grey red green yellow blue purple cyan white; do
#             printf "$(CLR $i$j "xx")"
#         done
#         echo
#     done
#     printf "\[\e[0m\]"
# }


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
