#!/usr/bin/env bash
# Installation des dépendances système

install_deps() {
    log_header "Dépendances système"

    local packages_file=""

    if command -v pacman &>/dev/null; then
        packages_file="$DOTFILES_DIR/packages/arch.txt"
        log_info "Arch Linux détecté"
    elif command -v apt &>/dev/null; then
        packages_file="$DOTFILES_DIR/packages/ubuntu.txt"
        log_info "Ubuntu/Debian détecté"
    else
        log_warning "Système non reconnu"
        return
    fi

    if [[ ! -f "$packages_file" ]]; then
        log_warning "Fichier de paquets introuvable: $packages_file"
        return
    fi

    log_info "Paquets à installer:"
    while read -r pkg; do
        [[ -n "$pkg" ]] && echo "  - $pkg"
    done < "$packages_file"

    if [[ "$DRY_RUN" == true ]]; then
        return
    fi

    # Installation réelle
    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed $(cat "$packages_file")
    elif command -v apt &>/dev/null; then
        sudo apt install -y $(cat "$packages_file")
    fi
}
