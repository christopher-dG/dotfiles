# General
export "PATH=$PATH:$HOME/.local/bin"
export ALTERNATE_EDITOR=""
export EDITOR="emacs -q -nw"
export LESSHISTFILE="-"
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"  # Requires package source-highlight.
export LESS=' -R '

# Python
PYTHON_DIR="$HOME/.config/python"
export PYTHONSTARTUP="$PYTHON_DIR/pythonrc.py"
export PYTHONHISTORY="$PYTHON_DIR/history"
[ -f "$PYTHONHISTORY" ] || touch "$PYTHONHISTORY"
[ -d "$HOME/.virtualenvs" ] && source virtualenvwrapper.sh

# Go
export GOPATH="$HOME/.go"
export PATH="$PATH:$GOPATH/bin"

# Rust
export PATH="$PATH:$HOME/.cargo/bin"

# Elixir
export ERL_AFLAGS="-kernel shell_history enabled"

# OCaml
command -v opam &> /dev/null && eval $(opam config env)

# Ruby
export PATH="$PATH:$HOME/.rvm/bin"

# asdf
[ -d "$HOME/.asdf" ] && source "$HOME/.asdf/asdf.sh"

# Private
[ -f "$HOME/.config/.privaterc" ] && source "$HOME/.config/.privaterc"
