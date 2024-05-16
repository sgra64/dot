# dotfiles

Dotfiles are configuration files that typically start with a `.` (dot) for
Unix-type systems such as: MacOS, Linux, BSD, Docker containers,
[Windows/WSL](https://learn.microsoft.com/en-us/windows/wsl/about),
Windows Unix-emulators such as
[cygwin](https://www.cygwin.com/) or GitBash.

Since dotfiles start with a `.`, they are sometimes hidden and not shown.
Make sure to enable showing hidden files on your system.

Dotfiles define settings of the environment (e.g.
[environment variables](https://opensource.com/article/19/8/what-are-environment-variables)
such as *PATH* to find commands or *CLASSPATH* to run Java programs).
They apply to specific applications, services and tools.


&nbsp;

Dotfiles are grouped into:

 - *system-wide* files that apply to the system/machine and all users.
    They are stored in folders associated with the system or application
    installations.

    For example: the system-wide (global)
    [*settings.json*]()
    file for the *VS Code* IDE resides in "C:\Users\user\AppData\Roaming\Code\User"
    on Windows.

 - *user* dotfiles apply to a user account and reside in the user's HOME-directory.

    Examples of dotfiles in the HOME directory are:

    - [*.profile*]():
        with commands executed when a new terminal is opened.
    
    - [*.bashrc*]():
        with commands when a new *bash* shell starts (command interpreter),
        e.g. when a new terminal is opened or *bash* command is invoked.

    - [*.zshrc*]():
        with commands when *zsh* shell starts (command interpreter for MacOS).

    - [*.gitconfig*]():
        with user settings for *git*.

    - [*.vimrc*]():
        settings for the *vi* editor.

    - [*.ssh*]():
        directory with PKI keys (e.g. `id_rsa.pub` and `id_rsa` public, private
        keys pairs).

 - *project* dotfiles reside in a project directory and are associated with the
    project.

    Examples of *project* dotfiles are:

    - [*.vscode*]():
        directory with configuration files for the *VS Code* IDE.

    - [*.project*](), [*.classpath*]():
        project configurations for *eclipse* and *VS Code* IDE.

    - [*.git/config*]():
        project *git* settings


&nbsp;

Read short article ["Dotfiles – What is a Dotfile and How to Create it in Mac and Linux"](https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/)
and answer questions:

1. What is the PATH environment variable?

1. Where and how is the PATH environment defined or adjusted?

1. What is prompt customization?

1. What are aliases and functions and where are they defined?

1. What does `->` mean in:
    ```sh
    lrwxrwxrwx 1  15 Apr 7 11:11 .profile -> .dotfiles/profile.sh
    ```

1. How is it created?


&nbsp;

Checkout GitHub's currated collection of
[awesome-dotfiles](https://github.com/webpro/awesome-dotfiles).
