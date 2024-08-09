
function sys_setup() {
    local main=$1
    local sub=$2
    [ "$LOG" = true ] && echo ".sys.Win-CYGWIN.sh: sys_setup() $1 $2"

    if [[ "$1" = "aliases" ]]; then
        shift
        # Ubuntu merges dotfiles and regular files in directory listings
        # stackoverflow: "Sorting directory contents (including hidden files) by name"
        # alias ls="LC_ALL=C ls -lA --group-directories-first $* "
    fi
}
