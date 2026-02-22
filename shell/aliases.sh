#!/usr/bin/env bash
# aliases.sh - Shared aliases for bash and zsh
# Sourced by both .bashrc and .zshrc

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- Listing ---
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias tree='tree -L 3 --dirsfirst'

# --- Safety ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# --- Grep ---
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# --- Git shortcuts ---
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate -20'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'
alias gst='git stash'

# --- Docker ---
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f'
alias dexec='docker exec -it'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# --- System ---
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# --- Ubuntu-specific package names ---
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *"ubuntu"* || "${ID_LIKE:-}" == *"debian"* ]]; then
        command -v fdfind &>/dev/null && ! command -v fd &>/dev/null && alias fd='fdfind'
        command -v batcat &>/dev/null && ! command -v bat &>/dev/null && alias bat='batcat'
    fi
fi

# --- Vim / NeoVim ---
if command -v nvim &>/dev/null; then
    alias vim='nvim'
    alias vi='nvim'
fi

# --- fzf helpers ---
if command -v fzf &>/dev/null; then
    alias vfzf='vim $(fzf)'
fi

# --- Misc ---
alias reload='exec $SHELL -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
