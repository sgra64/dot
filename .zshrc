# Created by newuser for 5.8
[ "$LOG" ] && echo .zshrc $1

# run .bashrc
[ -f .bashrc ] && source .bashrc $([ "$WINDIR" ] && echo "Win:ZSH" || echo "Mac:ZSH")
