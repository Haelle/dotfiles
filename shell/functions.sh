#!/usr/bin/env bash
# functions.sh - Shared functions for bash and zsh

# g - git shortcut: no args = git status, with args = git passthrough
g() {
    if [[ $# -eq 0 ]]; then
        git status
    else
        git "$@"
    fi
}

# mkcd - create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# extract - extract any archive format
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <file>"
        return 1
    fi

    if [[ ! -f "$1" ]]; then
        echo "'$1' is not a valid file"
        return 1
    fi

    case "$1" in
        *.tar.bz2)   tar xjf "$1"    ;;
        *.tar.gz)    tar xzf "$1"    ;;
        *.tar.xz)    tar xJf "$1"    ;;
        *.bz2)       bunzip2 "$1"    ;;
        *.rar)       unrar x "$1"    ;;
        *.gz)        gunzip "$1"     ;;
        *.tar)       tar xf "$1"     ;;
        *.tbz2)      tar xjf "$1"    ;;
        *.tgz)       tar xzf "$1"    ;;
        *.zip)       unzip "$1"      ;;
        *.Z)         uncompress "$1" ;;
        *.7z)        7z x "$1"       ;;
        *.xz)        xz -d "$1"      ;;
        *.zst)       zstd -d "$1"    ;;
        *)           echo "Cannot extract '$1': unknown format" ;;
    esac
}

# jwt - decode a JWT token (header + payload)
jwt() {
    if [[ -z "$1" ]]; then
        echo "Usage: jwt <token>"
        return 1
    fi

    local token="$1"

    # Decode header
    echo "=== Header ==="
    echo "$token" | cut -d'.' -f1 | base64 -d 2>/dev/null | jq . 2>/dev/null || echo "(invalid)"

    # Decode payload
    echo "=== Payload ==="
    echo "$token" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq . 2>/dev/null || echo "(invalid)"
}

# fshow - git log browser with fzf
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --bind "ctrl-m:execute(echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs git show --color=always | less -R)"
}

# fkill - kill process with fzf
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -"${1:-9}"
    fi
}

# tre - tree with less
tre() {
    tree -aC -I '.git|node_modules|vendor|.cache' --dirsfirst "$@" | less -FRNX
}

# up - go up N directories
up() {
    local count="${1:-1}"
    local path=""
    for ((i = 0; i < count; i++)); do
        path="../$path"
    done
    cd "$path" || return
}

# serve - quick HTTP server in current directory
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}
