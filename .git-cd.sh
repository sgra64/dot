export GIT_PROJECT=""
export GIT_PATH=""
# 
[ "$LOG" = true ] && echo "git_prompt.sh $1"

# overlay cd to update $GIT_PROJECT and $GIT_PATH
function cd() {
    local git_project_prior=$GIT_PROJECT
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
    if [ -z "$git_project_prior" -a "$GIT_PROJECT" ]; then
        # entering $GIT_PROJECT
        echo "entering GIT_PROJECT: $GIT_PROJECT"
    fi
    if [ "$git_project_prior" -a -z "$GIT_PROJECT" ]; then
        # leaving $git_project_prior
        echo "leaving GIT_PROJECT: $git_project_prior"
    fi
}
