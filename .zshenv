CONFIG="$HOME/.config"
SHARE="$HOME/.local/share"

# General
export ZDOTDIR="$CONFIG/zsh"
export DISPLAY="$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0"
export MAKEFLAGS="-j$(nproc)"
export PATH="$PATH:$HOME/.local/bin"
export ALTERNATE_EDITOR=""
export EDITOR="emacs -q -nw"
export LESSHISTFILE="-"

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
export JULIA_NUM_THREADS="$(nproc)"
export JULIA_PROJECT="@."

export JUPYTER="$(which jupyter)"
export JUPYTER_CONFIG_DIR="$CONFIG/jupyter"

# TODO: Why doesn't this work?
# export irbrc="$SHARE/ruby/irbrc"

export ERL_AFLAGS="-kernel shell_history enabled"

export ASDF_DATA_DIR="$SHARE/asdf"
[ -d "/opt/asdf-vm" ] && source "/opt/asdf-vm/asdf.sh"

[ -f "$CONFIG/.privaterc" ] && source "$CONFIG/.privaterc"
