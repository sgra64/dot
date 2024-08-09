function sys_setup() {
    local main=$1
    local sub=$2
    [ "$LOG" = true ] && echo ".sys.WSL-Ubuntu.sh: sys_setup() $1 $2"

    if [ "$main" = "aliases" ]; then
        shift
        # 
        case "$sub" in
        mono) shift ;;
        color) shift
            # overwrite colors for:
            # - ex: red -> low-white (WSL:Ubuntu shows all files as executable),
            # - ln, or: blue -> cyan
            export LS_COLORS+=":"$(ls_colors \
                "ex"    low-white \
                "ln"    cyan \
                "or"    cyan \
            ) ;;
        esac
        # 
        alias l="LC_ALL=C ls -lA --group-directories-first $*"
        alias ls="LC_ALL=C ls -lA --group-directories-first $*"
    fi
}
