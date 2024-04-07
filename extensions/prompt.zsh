# Find and set branch name var if in git repository.
# https://medium.com/pareture/simplest-zsh-prompt-configs-for-git-branch-name-3d01602a6f33
function branch_name_or_time() {
    # local mag="%{$fg[magenta]%}"
    local mag=$1    #"%F{197}"
    local white=$2  # "%{$fg[white]%}"
    # branch=$(git symbolic-ref --short HEAD &>/dev/null || echo "?")
    local branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
    [ "$branch" ] && echo "$white""[$mag$branch$white]" || echo "($(date '+%H:%M'))"
}

# Enable substitution in the prompt.
setopt prompt_subst

# Config for prompt. PS1 synonym.
# prompt='%2/ $(git_branch_name) > '


[[ $cmdcount -ge 1 ]] || cmdcount=1
preexec() { ((cmdcount++)) }
# PS1='$cmdcount '                # notice the single(!) tics

# set terminal to color mode (if terminal supports color)
function prompt_colored() {
    # Only allow color when terminal supports colors. Test with $(tput colors),
    # see: https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
    if [ $(tput colors) ]; then
        export COLOR="on"
        # 
        # set colored prompt
        # https://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text
        autoload -U colors && colors
        PS1=""
        PS1+="%{$fg[magenta]%}"
        PS1+="\$cmdcount "
        PS1+="%{$fg[blue]%}"
        PS1+="%n@"
        PS1+="$SYS_NAME "
        PS1+="%{$fg[white]%}"
        # PS1+="\$(branch_name_or_time \"%F{197}\" \"%{$fg[white]%}\") "
        PS1+="\$(branch_name_or_time \"%{$fg[red]%}\" \"%{$fg[white]%}\") "
        PS1+="%{$fg[yellow]%}"
        PS1+="%~ "
        PS1+="%{$reset_color%}"
        PS1+=">"
        PS1+="%{$fg[white]%}"

        export LS_COLORS="di=1;37:ow=1;37:ln=1;34:fi=0;37:ex=0;37:*.tar=0;36"
    else
        set_monochrome $1
    fi
}

function set_prompt() {
    # PS1="\u@\h $ "
    # build monochrome prompt
    # [ "$1" == "on" -a "$( type set_PS1_prompt_colored &>/dev/null | grep 'function' )" ] && \
    #     set_PS1_prompt_colored || set_PS1_prompt
    if [[ "$1" == "on" && "$(type prompt_colored 2>/dev/null | grep 'function')" ]]; then
        prompt_colored
        # trap "echo -ne '\e[m'" DEBUG
    else
        PS1="\$cmdcount %n@$SYS_NAME "
        PS1+="\$(branch_name_or_time) "
        PS1+="%~ >"
    fi
}
