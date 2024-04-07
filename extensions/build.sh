#------------------------------------------------------------------------------
# "built" dotfiles by linking/copying from git directory to $HOME directory
# must be sourced separately
#------------------------------------------------------------------------------
# 
function build() {
    local func=$FUNCNAME    # zsh: funcstack[1]
    # 
    declare -A links=(
        [".profile"  ]=".dot/profile.rc"
        [".bashrc"   ]=".dot/startup.rc"
        [".zprofile" ]=".dot/profile.rc"
        [".zshrc"    ]=".dot/startup.rc"
        [".minttyrc" ]=".dot/mintty.rc"
        [".vimrc"    ]=".dot/vim.rc"
        # [".m2"       ]="/c/Users/svgr2/.m2"
        # ["desktop"   ]="/c/Users/svgr2/Desktop"
    )
    declare -A copies=(
        [".gitconfig"]=".dot/gitconfig"
    )
    # add entires to wire .m2 and desktop on windows, e.g. [".m2"]="/c/Users/svgr2/.m2"
    [ ! -z "${USERPROFILE}" ] && \
        links[".m2"]+="$(cygpath $USERPROFILE)/.m2" && \
        links["desktop"]+="$(cygpath $USERPROFILE)/Desktop"
    # 
    # add entries to link/copy .vscode dotfiles when VS Code is installed
    [ ! -z "${VSCODE_CONFIG}" ] && \
        links[".settings.json"]+="${VSCODE_CONFIG}/settings.json" && \
        copies["\$VSCODE_CONFIG/settings.json"]+=".dot/vscode/settings.json" && \
        copies["\$VSCODE_CONFIG/launch.json"]+=".dot/vscode/launch.json" && \
        copies["\$VSCODE_CONFIG/keybindings.json"]+=".dot/vscode/keybindings.json"
    # 
    if [ ! "$HOME" = $(pwd) ]; then
        echo "must run in \$HOME directory"
    else
        if [ "$*" ]; then
            local all="${@:1:$#-1}" # all args but last
            local last="${@:$#}"    # last arg
            case "$last" in
                show) echo "${!links[@]}" "${!copies[@]}" | tr ' ' '\n' | grep -v '^$' ;;
                wipe) echo "rm -f $(echo $($func show | grep -v VSCODE_CONFIG))" ;;   # except global vscode files
                all) for k in "${!links[@]}"; do
                        echo "[ -L $k ] || ln -s ${links[$k]} $k"
                    done
                    for k in "${!copies[@]}"; do
                        echo "[ -f $k ] || cp ${copies[$k]} $k"
                    done ;;
                --exec) [ "$all" ] && \
                    ($func $all | tee /dev/tty | ${SHELL}) && echo "done." ;;
                --help|*) echo "usage: $func all wipe show [--exec, --help]"
            esac
        else $func "--help"
        fi
    fi
}