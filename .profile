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
export LOG=false
if [ "$LOG" = true ]; then
    [ "$ZSH" ] && echo ".zprofile $1; echo .profile $1"
fi

# umask 022 permissions of new files are 644 (files) and 755 (directories)
umask 022

# set LANG environment variable, otherwise git prints German messages
export LANG=en_US.UTF-8

export HOSTNAME_ALIAS=$(hostname)
case $HOSTNAME_ALIAS in
    LAPTOP-V50CGD0T)
        export HOSTNAME_ALIAS="X1-Carbon" ;;
esac

case $(uname -s) in
    # 
    CYGW*|MINGW*)
        export SYS=$([ "$MSYSTEM" ] && echo "Win:MINGW" || $([ "$1" ]) && echo $1 || echo "Win:CYGWIN")
        # 
        # source_addons $sys     # call before env_Windows
        # 
        # call function to set up environment on Windows for Cygwin and MINGW (GitBash)
        [ -f ~/.env-windows.sh ] && \
            source ~/.env-windows.sh && \
            env_Windows     # call env_Windows() function
        ;;
    # 
    *Linux)
        export SYS="Linux"
        export PATH=".:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        if [ "$WSL_DISTRO_NAME" = "Ubuntu" ]; then
            export SYS="WSL:Ubuntu"
            [ -f ~/.bashrc ] && source ~/.bashrc
        fi
        ;;
    # 
    *) echo '~/.profile: $(uname -s) unmatched' ;;
esac

[ -z "$HAS_GIT" ] && \
    export HAS_GIT=$(git --version >/dev/null 2>/dev/null; [[ $? = 0 ]] && echo true || echo false)

# bash does not run .bashrc when terminal opened (call here), zsh runs .zshrc
[ -f ~/.bashrc -a "$1" != "Win:ZSH" ] && \
    source ~/.bashrc

# show dotfiles first and not merged with 'ls' (as WSL:Ubuntu did)
export LC_COLLATE="C"

# remove functions and variables no longer needed
unset env_Windows
