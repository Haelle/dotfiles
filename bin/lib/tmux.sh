#!/usr/bin/env bash
# Installation de la configuration tmux

install_tmux() {
    log_header "tmux"

    local source="$DOTFILES_DIR/tmux/tmux.conf"
    local target="$HOME/.tmux.conf"

    if [[ ! -f "$source" ]]; then
        log_error "Fichier source introuvable: $source"
        return 1
    fi

    create_symlink "$source" "$target" "tmux.conf"
}
