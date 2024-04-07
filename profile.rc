#------------------------------------------------------------------------------
# entry script executed when a new terminal is opened ("login shell").
#------------------------------------------------------------------------------
# cygwin: change /etc/fstab to: none / cygdrive binary,posix=0,user,noacl 0 0
umask 022

# set LANG environment variable, otherwise git prints German messages
export LANG=en_US.UTF-8

# executed when a new Terminal is opened on Windows systems only
function profile_windows() {
    export STARTUP_PATH=".:/usr/local/bin:/usr/bin:/bin"
    local PowershellPath="$(cygpath ${SYSTEMROOT})/system32/WindowsPowerShell/v1.0"
    export WIN_PATH="$(cygpath ${SYSTEMROOT}):$(cygpath ${SYSTEMROOT})/system32:${PowershellPath}"
    # 
    # ignore Windows \r line ends, otherwise error: '\r': command not found in .bashrc
    (set -o igncr) 2>/dev/null && set -o igncr; # this comment is needed
    # 
    # change Windows default code page (437) to UTF-8 (65001), see:
    # https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
    $(cygpath ${SYSTEMROOT})/system32/chcp.com 65001 &>/dev/null
}

# executed when a new Terminal is opened
function profile() {
    # map system name obtained from 'uname -n' to appearance in prompt
    declare -A sys_names=(
        ["LAPTOP-V50CGD0T"]="X1"
    )
    local sys_name=$(uname -n)
    local lookup_name=${sys_names[$sys_name]}
    export SYS_NAME=$( [ $lookup_name ] && echo $lookup_name || echo $sys_name )
    # 
    # macOS: use uname -s (not -o), see: https://www.unix.com/man-page/osx/1/uname
    case $(uname -s) in
        CYGW*)
            case $(ps -p $$) in # or: "${SHELL}"
            *bash)  profile_windows ;;
            *zsh)   local is_zsh=true; profile_windows ;;
            *) echo '~/.profile: "$(ps -p $$)" unmatched' ;;
            esac ;;
        #
        MINGW*)  profile_windows ;;
        *Linux) export STARTUP_PATH="${PATH}" ;;
        *) echo '~/.profile: $(uname -s) unmatched' ;;
    esac

    # login shell executes ~/.profile, but not ~/.bashrc, except zsh
    # call ~/.bashrc here (except for zsh), links to startup_shell.rc
    [ -f ~/.bashrc -a ! "$is_zsh" ] && source ~/.bashrc
    # 
    # cygwin bash calls /etc/profile before ~/.profile, /etc in C:/opt/cygwin64/etc
    # zsh calls /etc/profile before ~/.profile (cygwin)
    # git-Bash calls /etc/profile from msys in C:/Program Files (x86)/Git/etc
}

# execute profile() function
profile

unset profile_windows profile
