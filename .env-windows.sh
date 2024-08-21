
function env_Windows() {
    # set/reset environment variables coming from Windows
    export USER=$(whoami)       # reset $USERID
    export USERNAME=${USER}     # reset $USERNAME
    export HOME=$(realpath $HOME)   # resolve linked $HOME
    export PWD=$HOME    # used by '\w' in PS1 prompt string

    # local append_path="$(cygpath ${SYSTEMROOT}):$(cygpath ${SYSTEMROOT})/system32"
    local append_path="$(cygpath ${SYSTEMROOT})"
    # 
    # https://medium.com/@linuxadminhacks/understanding-ifs-in-bash-scripting-3c67a39661e9
    IFS=@; for p in $(echo $PATH | tr ':' '@'); do
        case "$p" in
        *system32|*PowerShell*|*WindowsApps*)
            append_path+=":$(cygpath $p)"
        esac
    done; unset IFS     # reset IFS to default values (space, tab, newline)
    # 
    # probe git is present, either cygwin git or GitBash git
    local git_path=$(which git 2>/dev/null)
    [ "$git_path" ] && git_path=$(cygpath "$git_path") && git_path=$(dirname "$git_path")
    # 
    local vscode_path=$(which code 2>/dev/null)
    [ "$vscode_path" ] && vscode_path=$(cygpath "$vscode_path") && vscode_path=$(dirname "$vscode_path")
    # 
    # reset PATH, remove windows entries
    export PATH=".:/usr/local/bin:/usr/bin:/bin:$append_path"
    # 
    [ -d "$git_path" ] && export PATH="${PATH}:$git_path"
    [ -d "$vscode_path" ] && export PATH="${PATH}:$vscode_path"

    # remove unessesary Windows environment variables
    unset FPS_BROWSER_USER_PROFILE_STRING \
        PROCESSOR_LEVEL TERM_PROGRAM_VERSION USERDOMAIN_ROAMINGPROFILE PROGRAMFILES \
        PATHEXT configsetroot OS HOMEDRIVE USERDOMAIN USERPROFILE PRINTER JD2_HOME \
        ALLUSERSPROFILE ORIGINAL_PATH CommonProgramW6432 VBOX_MSI_INSTALL_PATH OneDrive \
        COMSPEC INFOPATH LOGONSERVER PSModulePath PROCESSOR_REVISION DriverData \
        COMMONPROGRAMFILES PROCESSOR_IDENTIFIER SESSIONNAME HOMEPATH TMP ProgramW6432 \
        MINTTY_SHORTCUT WINDIR FPS_BROWSER_APP_PROFILE_STRING PROCESSOR_ARCHITECTURE \
        PUBLIC SYSTEMDRIVE OneDriveCommercial OLDPWD ProgramData

    # ignore Windows \r line ends, otherwise error: '\r': command not found in .bashrc
    (set -o igncr) 2>/dev/null && set -o igncr;
    # 
    # change Windows default code page (437) to UTF-8 (65001), see:
    # https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
    $(cygpath ${SYSTEMROOT})/system32/chcp.com 65001 &>/dev/null
}
