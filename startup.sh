#------------------------------------------------------------------------------
# entry script executed when a new shell starts: bash, gitbash or zsh (Mac),
# e.g. after new terminal is opened or a new shell is started.
# rc-files: .bashrc, .zshrc files link here.
#------------------------------------------------------------------------------

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return ;;
esac

# reset PATH to STARTUP_PATH to avoid PATH+= accumulation
[ "${STARTUP_PATH}" ] && export PATH=${STARTUP_PATH}

dot_path="$HOME/.dot"
dot_path_ext="$dot_path/extensions"

# execute when any shell starts (bash, gitbash or zsh)
function startup_common() {
    # 
    # test works for bash and zsh
    type shopt &>/dev/null && if [[ $? ]]; then
        # check window size after each command and update values of LINES and COLUMNS
        shopt -s checkwinsize
        # append to the history file, don't overwrite it
        shopt -s histappend
    fi
    # don't put duplicate lines or lines starting with space in the history.
    HISTCONTROL=ignoreboth
    HISTSIZE=999
    HISTFILESIZE=999

    # set aliases for colored output, if colors are available
    alias h="history "
    alias l="ls -alFog --color=auto "
    alias ls="ls -A --color=auto "
    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
    alias pwd="pwd -LP"     # show path with resolved links
}

# execute when cygwin bash starts
function startup_bash() {
    [[ "$1" != "--no-paths" ]] && \
        source $dot_path/paths.sh
    # 
    source $dot_path_ext/color.sh
    source $dot_path_ext/prompt.sh
    source $dot_path_ext/prompt_colored.sh
    source $dot_path_ext/git.sh
    # 
    color $COLOR on
}

# execute when gitbash starts
function startup_gitbash() {
    # reuse bash startup
    startup_bash
    # 
    # export PATH="${PATH}:/c/Program Files (x86)/Git/bin"
    # 
    # Stop GitBash (MinGW and MSYS) from altering path names (needed to run docker ... //bin/sh)
    # prevent error: failed to create shim task: OCI runtime create failed: runc create failed:
    # unable to start container process: exec: "C:/Program Files (x86)/Git/usr/bin/sh.exe":
    # stat C:/Program Files (x86)/Git/usr/bin/sh.exe: no such file or directory: unknown.
    export MSYS_NO_PATHCONV=1
    #
    # prefix docker with 'winpty' to prevent error: input device is not a TTY
    alias docker='winpty docker'
}

# execute when zsh starts (Mac)
function startup_zsh() {
    source $dot_path/paths.sh
    source $dot_path_ext/color.sh
    source $dot_path_ext/prompt.zsh
    source $dot_path_ext/git.sh
    # 
    color $COLOR on
}

# execute when bash starts in WSL (Windows-Subsystem-for_Linux)
function startup_wsl_bash() {
    # reuse bash startup
    startup_bash --no-paths
}

# execute instructions common to all environments
startup_common

# identify system/shell and execute corresponding startup function
# macOS: use uname -s (not -o), https://www.unix.com/man-page/osx/1/uname
case "$(uname -s)" in

    CYGW*)  # Cygwin environment (Windows)
        case $(ps -p $$) in # or: "${SHELL}"
        *bash)  startup_bash ;;
        *zsh)   export SHELL="/bin/zsh"; startup_zsh ;;
        *) echo '~/.bashrc: "$(ps -p $$)" unmatched' ;;
        esac
        ;;

    MINGW*) # mingw environment (GitBash on Windows)
        startup_gitbash
        ;;

    *Linux) # WSL/Ubuntu environment
        export HOME="$HOME/home"  # append mount path in WSL
        dot_path="$HOME/.dot"
        dot_path_ext="$dot_path/extensions"
        startup_wsl_bash
        cd $HOME
        ;;

    *) echo '~/.bashrc: $(uname -s) unmatched' ;;
esac

# append WIN_PATH to PATH for Windows systems, if present
[ "${WIN_PATH}" ] && export PATH="${PATH}:${WIN_PATH}"

# remove functions and variables that are no longer needed
unset startup_common startup_bash startup_gitbash startup_zsh startup_wsl_bash dot_path
