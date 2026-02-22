#!/usr/bin/env bash
# symlink.sh - Orchestrate symlink deployment for offline and online modes

# Deploy symlinks common to both modes
deploy_common_symlinks() {
    header "Deploying symlinks"

    make_symlink "$DOTFILES_DIR/shell/aliases.sh"          "$HOME/.aliases"
    make_symlink "$DOTFILES_DIR/shell/functions.sh"        "$HOME/.functions"
    make_symlink "$DOTFILES_DIR/shell/bashrc"              "$HOME/.bashrc"
    make_symlink "$DOTFILES_DIR/git/gitconfig"             "$HOME/.gitconfig"
    make_symlink "$DOTFILES_DIR/git/gitignore_global"      "$HOME/.gitignore_global"
    make_symlink "$DOTFILES_DIR/tmux/tmux.conf"            "$HOME/.tmux.conf"
    make_symlink "$DOTFILES_DIR/ssh/config"                "$HOME/.ssh/config"
    make_symlink "$DOTFILES_DIR/vim/vimrc"                 "$HOME/.vimrc"
    make_symlink "$DOTFILES_DIR/ctags/ctags.d"             "$HOME/.ctags.d"
    make_symlink "$DOTFILES_DIR/shell/starship.toml"       "$HOME/.config/starship.toml"
}

# Deploy offline-specific symlinks
deploy_offline_symlinks() {
    deploy_common_symlinks
    make_symlink "$DOTFILES_DIR/shell/zshrc-offline"       "$HOME/.zshrc"
    success "Offline symlinks deployed"
}

# Deploy online-specific symlinks
deploy_online_symlinks() {
    deploy_common_symlinks
    make_symlink "$DOTFILES_DIR/shell/zshrc-online"        "$HOME/.zshrc"
    make_symlink "$DOTFILES_DIR/nvim"                      "$HOME/.config/nvim"
    success "Online symlinks deployed"
}
