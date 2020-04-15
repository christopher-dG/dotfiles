# General
export MAKEFLAGS="-j$(nproc)"
export "PATH=$PATH:$HOME/.local/bin"
export ALTERNATE_EDITOR=""
export EDITOR="emacs -q -nw"
export LESSHISTFILE="-"
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"  # Requires package source-highlight.
export LESS=" -R "

CONFIG="$HOME/.config"
SHARE="$HOME/.local/share"

# Cleaning up the home directory.
export GNUPGHOME="$SHARE/gnupg"
export DOCKER_CONFIG="$CONFIG/docker"
AWS="$CONFIG/aws"
export AWS_CONFIG_FILE="$AWS/config"
export AWS_SHARED_CREDENTIALS_FILE="$AWS/credentials"

PYTHON="$SHARE/python"
export PYTHONSTARTUP="$PYTHON/pythonrc"
export PYTHONHISTORY="$PYTHON/history"
[ -f "$PYTHONHISTORY" ] || touch "$PYTHONHISTORY"
export WORKON_HOME="$PYTHON/virtualenvs"

export GOPATH="$SHARE/go"
export PATH="$PATH:$GOPATH/bin"

export JULIA_DEPOT_PATH="$SHARE/julia"
export JULIA_HISTORY="$JULIA_DEPOT_PATH/logs/history"
export JULIA_PROJECT="@."

# TODO: Why doesn't this work?
# export irbrc="$SHARE/ruby/irbrc"

export ERL_AFLAGS="-kernel shell_history enabled"

# asdf
export ASDF_DATA_DIR="$SHARE/asdf"
[ -d "/opt/asdf-vm" ] && source "/opt/asdf-vm/asdf.sh"

# Private
[ -f "$CONFIG/.privaterc" ] && source "$CONFIG/.privaterc"
