# General-purpose aliases — symlinked into oh-my-zsh custom.
# Work-specific (labgrid, testrack) aliases live in dotfiles/work/zsh/aliases-work.zsh

# ── Git extras ─────────────────────────────────────────────────────────────────
alias gd="git diff"
alias gdc="git diff --cached"
alias gco="git checkout"
alias gb="git branch"
alias gl="git log --oneline --graph --decorate"
alias gst="git status -sb"
alias gcm="git commit -m"

# ── Navigation / misc ──────────────────────────────────────────────────────────
alias c="clear"
alias h="history"
alias tree="tree -C"
alias du1="du -h --max-depth=1 | sort -h"
alias grep="grep --color=auto"
alias mkdir="mkdir -p"
alias diff="diff --color=auto"
