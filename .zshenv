CONFIG="$HOME/.config"
SHARE="$HOME/.local/share"
export ZDOTDIR="$CONFIG/zsh"
export DISPLAY="$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0"
export MAKEFLAGS="-j$(nproc)"
export PATH="$PATH:$HOME/.local/bin"
export EDITOR="emacsclient -ta nano"
export GNUPGHOME="$SHARE/gnupg"
export PASSWORD_STORE_DIR="$SHARE/pass"
export PSQL_HISTORY="$SHARE/postgresql/history"
export DOCKER_CONFIG="$CONFIG/docker"
AWS="$CONFIG/aws"
export AWS_CONFIG_FILE="$AWS/config"
export AWS_SHARED_CREDENTIALS_FILE="$AWS/credentials"
export LESSHISTFILE="-"
export ASDF_DATA_DIR="$SHARE/asdf"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$CONFIG/asdf/tool-versions"
export SOLARGRAPH_CACHE="$SHARE/solargraph/cache"
export NODE_OPTIONS="--experimental-repl-await"
export NODE_REPL_HISTORY="$SHARE/node/history"
export GEM_HOME="$SHARE/gem"
export HEX_HOME="$SHARE/hex"
export MIX_HOME="$SHARE/mix"
export CCACHE_DIR="$SHARE/ccache"
PYTHON="$SHARE/python"
export PYTHONSTARTUP="$PYTHON/pythonrc"
export PYTHONHISTORY="$PYTHON/history"
[ -f "$PYTHONHISTORY" ] || touch "$PYTHONHISTORY"
export GOPATH="$SHARE/go"
export PATH="$PATH:$GOPATH/bin"
export GO111MODULE="on"
export IRBRC="$SHARE/ruby/irbrc"
export PATH="$PATH:$SHARE/gem/bin"
export JULIA_DEPOT_PATH="$SHARE/julia"
export JULIA_PKG_DEVDIR="$HOME/code"
export JULIA_HISTORY="$JULIA_DEPOT_PATH/logs/history"
export JULIA_NUM_THREADS="$(nproc)"
export JULIA_PROJECT="@."
export IPYTHONDIR="$SHARE/ipython"
export JUPYTER="$(which jupyter)"
export JUPYTER_CONFIG_DIR="$CONFIG/jupyter"
export ERL_AFLAGS="-kernel shell_history enabled"
export OPAMROOT="$SHARE/opam"
export GTK2_RC_FILES="/usr/share/themes/Arc-Dark/gtk-2.0/gtkrc"
[ -f "$CONFIG/.privaterc" ] && source "$CONFIG/.privaterc"
[ -d "/opt/asdf-vm" ] && source "/opt/asdf-vm/asdf.sh"
