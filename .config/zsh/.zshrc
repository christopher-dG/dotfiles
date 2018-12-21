# Completion.
autoload -Uz compinit && compinit
zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}"
zstyle ":completion:*:descriptions" format "%U%B%d%b%u"
zstyle ":completion:*:warnings" format " No matches."
setopt COMPLETE_ALIASES
setopt INTERACTIVE_COMMENTS

# Git branch display.
autoload -Uz vcs_info
zstyle ":vcs_info:*" enable git && zstyle ":vcs_info:git*" formats "[ %b ]"
precmd() { vcs_info }

# History.
HISTSIZE=2000
SAVEHIST=2000
HISTFILE="$ZDOTDIR/history"
setopt hist_ignore_all_dups
setopt hist_ignore_space
unsetopt BANG_HIST

# Prompt.
setopt PROMPT_SUBST
PS1="%(?..%B x %b)%(!.(root) .)%F{2}[%f %F{5}%~%f %F{2}] "
RPROMPT='$vcs_info_msg_0_'

# ls aliases and corrections.
alias ls="ls --color"
alias la="ls -a"
alias ll="ls -l"
alias sl="ls"
alias cd..="cd .."

# Git helpers.
alias gc="git commit -m"
alias gp="git push origin"
alias gs="git status"
alias ga="git add"
alias gch="git checkout"
gcl() { git clone "git@github.com:christopher-dG/$1.git" $2 }

# Misc.
alias julia='julia --project -q'
alias rs='redshift -PO'
man() {  # Coloured man pages.
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}
