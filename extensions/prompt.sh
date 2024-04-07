# for prompt, variable PN holds the project name, which is the name of the
# closest-up directory that has a .git directory - variable P1 contains the
# path stripped off $HOME and/or project path
[ -z "$PN" ] && export PN=""
[ -z "$P1" ] && export P1="~"

# overlay cd to update $PN and $P1
function cd() {
    local path=$( [ -z "$1" ] && echo ~ || echo $1 ); shift
    builtin cd "$path" $*       # actual change of directory
    # path=$(realpath . )       # full path (pwd does not realify links)
    path=$(pwd -LP)             # full path (-P with symbolic links resolved)
    PN=$(project_name)          # execute function to find project name (or empty)
    if [ "$PN" ]; then
        P1="~"${path#*${PN}}    # inside git project, strip path-prefix
    else
        local home_dir=$(realpath $HOME)    # within $HOME, strip path to $HOME
        local strip=${path#*${home_dir}}    # else: use full path for P1
        [ "$path" = "$strip" ] && P1="${strip}" || P1="~${strip}"
    fi
}

# return (echo) name of closest directory with a .git directory by
# traversing a current path upwards or return ""
function project_name() {
    local gdir=".git"
    IFS='/' read -ra parr <<< "$(realpath $(pwd))"
    # walk path from leaf up, tac reverses order
    for pd in $(printf '%s\n' "${parr[@]}" | tac); do
        [ -d $gdir ] && echo $pd && return
        gdir="../"${gdir}
    done
}

# return (echo) branch name "[main]" or clock "[20:08]"
function branch_or_clock() {
    local brn=$(git symbolic-ref --short HEAD 2>/dev/null)
    [ "$PN" ] && echo "$PN~[$brn]" || echo "($(date '+%H:%M'))"
}

# return (echo) PS1 default prompt (no coloring)
function prompt() {
    echo "\# \u@$SYS_NAME \$(branch_or_clock) $(echo \$P1)"
}

# set PS1 variable for prompt, colored if called with: set_prompt on
# and prompt_color function has been sourced
function set_prompt() {
    # PS1="\u@\h $ "
    if [ "$1" == "on" -a "$(type prompt_colored 2>/dev/null | grep function)" ]; then
        PS1=$(prompt_colored)
        trap "echo -ne '\e[m'" DEBUG
    else
        # use monochrome prompt
        PS1=$(prompt)
        trap "" DEBUG
    fi
    PS1+="
"   # add newline to prompt (needed in this form)
}
