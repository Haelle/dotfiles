#!/usr/bin/env bash
# Installation de la configuration SSH

install_ssh() {
    log_header "SSH"

    local source="$DOTFILES_DIR/ssh/ssh_config"
    local target="$HOME/.ssh/config"
    local sockets_dir="$HOME/.ssh/sockets"

    if [[ ! -f "$source" ]]; then
        log_error "Fichier source introuvable: $source"
        return 1
    fi

    # Créer le dossier .ssh si nécessaire
    if [[ ! -d "$HOME/.ssh" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh"
        else
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"
        fi
    fi

    # Créer le dossier sockets pour le multiplexing
    if [[ ! -d "$sockets_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "mkdir -p $sockets_dir"
        else
            mkdir -p "$sockets_dir"
        fi
    fi

    create_symlink "$source" "$target" "ssh/config"

    # Permissions correctes
    if [[ "$DRY_RUN" != true ]]; then
        chmod 600 "$target"
    fi
}
