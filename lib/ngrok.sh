#!/usr/bin/env bash
# Installation de ngrok

install_ngrok() {
    log_header "ngrok"

    if command -v ngrok &>/dev/null; then
        log_info "ngrok déjà installé"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Installation de ngrok via le dépôt officiel"
        return
    fi

    log_info "Installation de ngrok..."

    if command -v apt &>/dev/null; then
        curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
            | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
        echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
            | sudo tee /etc/apt/sources.list.d/ngrok.list
        sudo apt update && sudo apt install -y ngrok
    elif command -v pacman &>/dev/null; then
        log_warning "Sur Arch, installer ngrok depuis l'AUR: yay -S ngrok"
        return
    else
        log_warning "Système non reconnu, installer ngrok manuellement: https://ngrok.com/download"
        return
    fi

    log_success "ngrok installé"
    log_info "Configurer le token: ngrok config add-authtoken <TOKEN>"
}
