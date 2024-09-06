# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo ".zshrc"

# run .bashrc
[ -f .bashrc ] && source .bashrc $([ "$WINDIR" ] && echo "Win:ZSH" || echo "Mac:ZSH")

unset -f prompt color
function prompt() { : }
function color() { : }

# PROMPT=$(colorize_prompt true "${reg_prompt[@]}")
# PROMPT=$'%{\e[32m%}> \u \h %{\e[0m%}'
# PROMPT="%F{green}hi>%f "
# 
# https://stackoverflow.com/questions/30199068/zsh-prompt-and-hostname
# https://stackoverflow.com/questions/57469946/dark-grey-background-color-in-zsh-using-autoload
autoload -U colors && colors
PS1="%{$fg[green]%}"
PS1+="%! "                      # history number
PS1+="%n@'${HOSTNAME_ALIAS}'"   # username from env variable
PS1+="%{$fg[white]%}"
PS1+=" (%T)"                    # time
# 
PS1+=" %{$fg_bold[yellow]%}"    # path in bright yellow
PS1+="%~ "                      # show current path relative to ~
# 
# PS1+=$'\e[1;33m '               # bright yellow in ANSI ESC spoils line end control
# PS1+="%~ "                      # show current path relative to ~
# PS1+=$'\e[0m'                   # reset coloring, spoils line end control
# PS1+=$'\[\e[0m\]'
# 
PS1+="%{$reset_color%}%"
PS1+=" > "


# otherwise, commands like: wc $(find tmp -name '*.py') ill-process first line
trap "" DEBUG

cd ~
