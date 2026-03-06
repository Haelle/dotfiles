#!/usr/bin/env bash
# Installation de la configuration SSH

install_ssh() {
    log_header "SSH"

    local source="$DOTFILES_DIR/ssh/ssh_config"
    local target="$HOME/.ssh/config"
    local sockets_dir="$HOME/.ssh/sockets"

    # Créer les dossiers nécessaires
    mkdir -p "$HOME/.ssh" "$sockets_dir"
    chmod 700 "$HOME/.ssh"

    create_symlink "$source" "$target" "ssh/config"

    # Permissions correctes
    if [[ "$DRY_RUN" != true ]]; then
        chmod 600 "$target"
    fi

    grep -q 'vim:.*ft=sshconfig' "$target.local" 2>/dev/null || echo '# vim: set ft=sshconfig:' >> "$target.local"
}
