
# macOS: use uname -s (not -o), see: https://www.unix.com/man-page/osx/1/uname
case $(uname -s) in
    # run .profile on Windows
    # CYGW*) local ZSH=true; [ -f .profile ] && source .profile ;;
    CYGW*) [ -f .profile ] && source .profile "Win:ZSH" ;;
esac
