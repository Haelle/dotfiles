#!/usr/bin/env bash
# Installation de la configuration tmux

install_tmux() {
    log_header "tmux"

    local source="$DOTFILES_DIR/tmux/tmux.conf"
    local target="$HOME/.tmux.conf"

    create_symlink "$source" "$target" "tmux.conf"
}
