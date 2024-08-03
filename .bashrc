# /etc/bash.bashrc has run before
[ "$LOG" ] && echo .bashrc called

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
alias pwd="pwd -LP"     # show real path with resolved links
alias rp="realpath "
alias path="echo \$PATH | tr ':' '\012'"

# append PATH (PATH+=does not work with zsh)
export PATH="${PATH}:/c/Program Files (x86)/Git/cmd"
export PATH="${PATH}:/c/Users/svgr2/AppData/Local/Programs/Microsoft VS Code/bin"

# leave .bashrc if called from .zshrc with 'source .bashrc ZSH'
[[ "$1" = "ZSH" ]] && return

# set a default prompt of: user@host and current_directory (adjusted from /etc/bash.bashrc)
#PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
PS1='\[\e]0;\w\a\]\\\\\\\\\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '

