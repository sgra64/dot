export GIT_PROJECT=""
export GIT_PATH=""
# 
[ "$LOG" = true ] && echo "git_prompt.sh $1"

# overlay cd to update $GIT_PROJECT and $GIT_PATH
function cd() {
    local prior_value_of_GIT_PROJECT=$GIT_PROJECT
    local cd_path=$( [ -z "$1" ] && echo $HOME || echo $1 ); shift
    # 
    # actually change directory
    builtin cd $cd_path $*
    # 
    export PWD=$(realpath . )   # used by '\w' in PS1 prompt string
    local git_project=""
    local dir=$PWD
    while [ "$dir" != "/" -a "$dir" != "$HOME" ]; do
        [ -d $dir/.git ] && \
            git_project=$(basename $dir) && \
            break
        dir=$(dirname $dir)
    done
    # 
    [ "$git_project" ] && \
        local path=$(pwd) && \
        export GIT_PATH=${path/$dir/\.} || \
        export GIT_PATH=""
    # 
    # rebuild PS1 prompt
    export GIT_PROJECT=$git_project
    prompt

    # test git-project was entered for the first time
    if [ -z "$prior_value_of_GIT_PROJECT" -a "$GIT_PROJECT" ]; then
        # sourcing when $GIT_PROJECT is entered
        # echo "entering GIT_PROJECT in: $dir"
        [ -f $dir/.env.sh ] && source $dir/.env.sh $GIT_PROJECT $dir && setup
    fi
    if [ "$prior_value_of_GIT_PROJECT" -a -z "$GIT_PROJECT" ]; then
        # wiping when leaving project
        # echo "leaving GIT_PROJECT: $prior_value_of_GIT_PROJECT"
        [ "$(typeset -f wipe)" ] && wipe $prior_value_of_GIT_PROJECT $dir
    fi
}
