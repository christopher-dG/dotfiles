# General
export "PATH=$PATH:$HOME/.local/bin"
export EDITOR="emacs"
export GIT_EDITOR="nano"
export LESSHISTFILE="-"
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"  # Requires package source-highlight.
export LESS=' -R '

# Python
PYTHON_DIR="$HOME/.config/python"
export PYTHONSTARTUP="$PYTHON_DIR/pythonrc.py"
export PYTHONHISTORY="$PYTHON_DIR/history"
export PIPENV_HIDE_EMOJIS=1
[ -f "$PYTHONHISTORY" ] || touch "$PYTHONHISTORY"

# Go
export GOPATH="$HOME/.go"
export PATH="$PATH:$GOPATH/bin"

# Rust
export PATH="$PATH:$HOME/.cargo/bin"

# Elixir
export ERL_AFLAGS="-kernel shell_history enabled"

# asdf
[ -d "$HOME/.asdf" ] && source $HOME/.asdf/asdf.sh

# Private
[ -f "$HOME/.config/.privaterc" ] && source "$HOME/.config/.privaterc"
