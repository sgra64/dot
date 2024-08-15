# Created by newuser for 5.8
[ "$LOG" ] && echo .zshrc $1

# run .bashrc
[ -f .bashrc ] && source .bashrc $([ "$WINDIR" ] && echo "Win:ZSH" || echo "Mac:ZSH")

# ZSH: 
PROMPT=$'%{\e[32m%}> %{\e[0m%}'

        
# function ansi_code_ZSH() {
#     # https://stackoverflow.com/questions/30568258/using-ansi-escape-sequences-in-zsh-prompt
#     local code=$1
#     local text=$2
#     local reset='%{\e[0m%}'     # alternatively: "\[\033[0m\]"
#     # 
#     case "$code" in
#     "reset")    printf "%s%s" "$reset" "$text" ;;
#     "0")        printf "0" ;;
#     *)          local esc=${ANSI_COLORS[$code]}
#                 [ "$text" = "--unterminated" ] && text="" && reset=""
#                 [ "$esc" ] && printf '%%{\e[%sm%%}%s%s' "$esc" "$text" "$reset" ;;
#     esac
# }
