# declare associative array with git aliases
declare -gA gt_aliases=(
      ["br"]="git branch -avv"
     ["log"]="git log --oneline --decorate"
     ["add"]="git add"
      ["rm"]="git rm --cached"
      ["ls"]="git log --name-status --oneline"
       ["r"]="git remote -v"
      ["sw"]="git switch"
    ["stat"]="git status"
)

# return (echo) git command from shortcut
function gt_cmd() {
    local args="${@:2:$#}"  # remaining args but first
    case "$1" in
        +)  gt_cmd add $args ;;
        -)  gt_cmd rm $args ;;
        show|--help)
            local key_order=("br" "log" "add" "rm" "ls" "r" "sw" "stat")
            for key in ${key_order[@]}; do
                echo -e "${key}:\t${gt_aliases[${key}]}"
            done ;;
        *)  # look up alias or return 'git status' as default
            [[ -z "$1" ]] && local alias="" || local alias=${gt_aliases[$1]}
            [[ -z "$alias" ]] && gt_cmd stat || echo $alias $args ;;
    esac
}

# execute or show git commands from shortcuts
function gt() {
    local func="gt" #bash: $FUNCNAME bash, zsh: funcstack[1]
    # 
    if [[ $(git status 2>/dev/null) ]]; then
        local args=(); local first=""
        local exec=false; local show=false
        for arg in "${@}"; do
            case "$arg" in       # last arg
            --exec) exec=true ;;
            --show) show=true ;;
            *) [ -z "$first" ] && first=$arg || args+=($arg) ;;
            esac
        done
        local direct_exec=(
            "br" "log" "add" "rm" "ls" "r" "sw" "stat"
        )
        local execute=false;
        if [[ ${direct_exec[@]} =~ $first ]]; then
            # fetch git command and execute when directly executable
            [[ $show == false ]] && execute=true
        else
            # fetch git command and execute with '--exec' and not '--show' options
            [[ $exec == true && $show == false ]] && execute=true
        fi
        # show git command when not executed
        [[ $execute == true ]] && \
            $(gt_cmd $first ${args[*]}) || \
            gt_cmd $first ${args[*]}
    else
        echo -e "must run \047$func\047 alias in a git project"
    fi
}

# 
# see examples of .gitconfig configurations
# https://github.com/mathiasbynens/dotfiles/blob/main/.gitconfig
# 