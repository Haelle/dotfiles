#!/usr/bin/env bash
# Installation de la configuration tmux

install_tmux() {
    log_header "tmux"

    create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf" "tmux.conf"

    # Scripts du dashboard Claude + helpers tmux
    create_symlink "$DOTFILES_DIR/tmux/cc-colors.sh" "$HOME/.config/tmux/cc-colors.sh" "tmux/cc-colors.sh"
    create_symlink "$DOTFILES_DIR/tmux/cc-bar.sh" "$HOME/.config/tmux/cc-bar.sh" "tmux/cc-bar.sh"
    create_symlink "$DOTFILES_DIR/tmux/cc-tabs.sh" "$HOME/.config/tmux/cc-tabs.sh" "tmux/cc-tabs.sh"
    create_symlink "$DOTFILES_DIR/tmux/cc-goto.sh" "$HOME/.config/tmux/cc-goto.sh" "tmux/cc-goto.sh"
    create_symlink "$DOTFILES_DIR/tmux/tmux-cheatsheet.sh" "$HOME/.config/tmux/tmux-cheatsheet.sh" "tmux/tmux-cheatsheet.sh"
}
