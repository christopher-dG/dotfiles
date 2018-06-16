export "PATH=$PATH:$HOME/.local/bin"
export EDITOR="emacs"
export GIT_EDITOR="nano"
export LESSHISTFILE="-"

if [ "$(which python)" ] || [ "$(which python3)" ]; then
    PYTHON_DIR="$HOME/.config/python"
    export PYTHONSTARTUP="$PYTHON_DIR/pythonrc.py"
    export PYTHONHISTORY="$PYTHON_DIR/history"
    export PIPENV_HIDE_EMOJIS=1
    touch "$PYTHONHISTORY"
fi

if [ "$(which go)" ]; then
    export GOPATH="$HOME/.go"
    export PATH="$PATH:$GOPATH/bin"
fi

if [ -d "$HOME/.cargo" ]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

if [ -d "$HOME/.hex" ]; then
    export ERL_AFLAGS="-kernel shell_history_enabled"
fi

if [ -d "$HOME/.android_sdk" ]; then
    export ANDROID_HOME="$HOME/.android_sdk"
    export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
fi

if [ -d "$HOME/.asdf" ]; then
    source $HOME/.asdf/asdf.sh
fi

if [ -f "$HOME/.config/.privaterc" ]; then
    source "$HOME/.config/.privaterc"
fi
