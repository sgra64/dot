# shell executes in order:
# - bash:
#   - /etc/profile
#   - /etc/bash.bashrc
#   - .profile
#   - .bashrc (sourced in .profile)
# - zsh:
#   - .zprofile calls --> .profile
#   - .zshrc calls --> .bashrc
# 

# export TERM=xterm-256color
# printf '\033[8;56;80t'

# turn on/off logging script execution
export LOG=true
if [ "$LOG" = true ]; then
    [ "$ZSH" ] && echo ".zprofile $1; echo .profile $1"
fi

# umask 022 permissions of new files are 644 (files) and 755 (directories)
umask 022

# set LANG environment variable, otherwise git prints German messages
export LANG=en_US.UTF-8

function env_Windows() {
    # set/reset environment variables coming from Windows
    export USER=$(whoami)
    export USERNAME=${USER}
    # export HOME=$(pwd)
    export HOMEPATH=$(realpath .)
    # 
    # local append_path="$(cygpath ${SYSTEMROOT}):$(cygpath ${SYSTEMROOT})/system32"
    local append_path="$(cygpath ${SYSTEMROOT})"
    # 
    IFS=@; for p in $(echo $PATH | tr ':' '@'); do
        case "$p" in
        *system32|*PowerShell*|*WindowsApps*)
            append_path+=":$(cygpath $p)"
        esac
    done; IFS=
    # 
    export PATH=".:/usr/local/bin:/usr/bin:/bin:$append_path"
    # 
    # ignore Windows \r line ends, otherwise error: '\r': command not found in .bashrc
    (set -o igncr) 2>/dev/null && set -o igncr; # this comment is needed
    # 
    # change Windows default code page (437) to UTF-8 (65001), see:
    # https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
    $(cygpath ${SYSTEMROOT})/system32/chcp.com 65001 &>/dev/null
}

function source_addons() {
    local sys_file=".rc-addons/."$(echo $1 | tr ':' '-')".sh"
    [ -f $sys_file ] && source $sys_file
}

case $(uname -s) in
    # 
    CYGW*|MINGW*)
        sys=$([ "$MSYSTEM" ] && echo "Win:MINGW" || $([ "$1" ]) && echo $1 || echo "Win:CYGWIN")
        # 
        source_addons $sys     # call before env_Windows
        # 
        # call function to set up environment on Windows for Cygwin and MINGW (GitBash)
        env_Windows
        # bash does not run .bashrc when terminal opened (call here), zsh runs .zshrc
        [ -f ~/.bashrc -a "$1" != "Win:ZSH" ] && \
            source ~/.bashrc $sys
        ;;
    # 
    *Linux)
        sys="Linux"
        export PATH=".:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
            sys="WSL:Ubuntu"
            source_addons $sys
            # export PATH+=":/mnt/c/Users/svgr2/AppData/Local/Programs/Microsoft VS Code/bin"
            [ -f ~/.bashrc ] && source ~/.bashrc $sys
        fi
        ;;
    # 
    *) echo '~/.profile: $(uname -s) unmatched' ;;
esac

# remove functions and variables that are no longer needed
unset env_Windows sys source_addons
