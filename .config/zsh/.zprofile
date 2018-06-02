export "PATH=$PATH:$HOME/.local/bin"
export EDITOR="emacs"
export GIT_EDITOR="nano"
export LESSHISTFILE="-"

if [ "$(which python)" ] || [ "$(which python3)" ]; then
    PYTHON_DIR="$HOME/.config/python"
    export PYTHONSTARTUP="$PYTHON_DIR/pythonrc.py"
    export PYTHONHISTORY="$PYTHON_DIR/history"
    touch "$PYTHONHISTORY"
fi

if [ "$(which go)" ]; then
    export GOPATH="$HOME/.go"
    export PATH="$PATH:$GOPATH/bin"
fi

if [ -d "$HOME/.cargo" ]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

if [ -d "$HOME/.asdf" ]; then
    source $HOME/.asdf/asdf.sh
fi

if [ -f "$HOME/.config/.privaterc" ]; then
    source "$HOME/.config/.privaterc"
fi
