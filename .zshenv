CONFIG="$HOME/.config"
SHARE="$HOME/.local/share"
export ZDOTDIR="$CONFIG/zsh"
export MAKEFLAGS="-j$(sysctl -n hw.physicalcpu)"
export PATH="$PATH:$HOME/.local/bin"
export EDITOR="emacs -Q -nw"
export GNUPGHOME="$SHARE/gnupg"
export PASSWORD_STORE_DIR="$SHARE/pass"
export DOCKER_CONFIG="$CONFIG/docker"
export DOCKER_BUILDKIT="1"
export DOCKER_HOST="ssh://ruby"
AWS="$CONFIG/aws"
export AWS_CONFIG_FILE="$AWS/config"
export AWS_SHARED_CREDENTIALS_FILE="$AWS/credentials"
export LESSHISTFILE="-"
export ASDF_DATA_DIR="$SHARE/asdf"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$CONFIG/asdf/tool-versions"
export SOLARGRAPH_CACHE="$SHARE/solargraph/cache"
export NODE_OPTIONS="--experimental-repl-await"
export NODEJS_CHECK_SIGNATURES="no"
export NODE_REPL_HISTORY="$SHARE/node/history"
export GEM_HOME="$SHARE/gem"
export HEX_HOME="$SHARE/hex"
export MIX_HOME="$SHARE/mix"
export CCACHE_DIR="$SHARE/ccache"
export GOPATH="$SHARE/go"
export PATH="$PATH:$GOPATH/bin"
export GO111MODULE="on"
export IRBRC="$SHARE/ruby/irbrc"
export PATH="$PATH:$SHARE/gem/bin"
export JULIA_DEPOT_PATH="$SHARE/julia"
export JULIA_PKG_DEVDIR="$HOME/code"
export JULIA_HISTORY="$JULIA_DEPOT_PATH/logs/history"
export JULIA_NUM_THREADS="$(sysctl -n hw.physicalcpu)"
export JULIA_PROJECT="@."
export IPYTHONDIR="$SHARE/ipython"
export JUPYTER="$(which jupyter)"
export JUPYTER_CONFIG_DIR="$CONFIG/jupyter"
export ERL_AFLAGS="-kernel shell_history enabled"
export OPAMROOT="$SHARE/opam"
[[ -z "$SSH_AUTH_SOCK" ]] && eval "$(ssh-agent -s)"
eval "$(/opt/homebrew/bin/brew shellenv)"
source "$(brew --prefix asdf)/asdf.sh"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
