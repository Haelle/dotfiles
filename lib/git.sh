#!/usr/bin/env bash
# Installation de la configuration Git

install_git() {
    log_header "Git"

    local source="$DOTFILES_DIR/git/gitconfig"
    local target="$HOME/.gitconfig"

    create_symlink "$source" "$target" "gitconfig"

    grep -q 'vim:.*ft=gitconfig' "$target.local" 2>/dev/null || echo '# vim: set ft=gitconfig:' >> "$target.local"
}
