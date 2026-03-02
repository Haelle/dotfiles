#!/usr/bin/env bash
# Installation de la configuration Git

install_git() {
    log_header "Git"

    local source="$DOTFILES_DIR/git/gitconfig"
    local target="$HOME/.gitconfig"

    if [[ ! -f "$source" ]]; then
        log_error "Fichier source introuvable: $source"
        return 1
    fi

    create_symlink "$source" "$target" "gitconfig"

    # Configuration du nom et email
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Prompt pour git user.name et user.email"
        return
    fi

    # Vérifier si name/email sont vides
    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null || true)
    current_email=$(git config --global user.email 2>/dev/null || true)

    if [[ -z "$current_name" ]]; then
        echo ""
        read -rp "Git user.name: " git_name
        if [[ -n "$git_name" ]]; then
            git config --global user.name "$git_name"
            log_success "user.name configuré: $git_name"
        fi
    else
        log_info "user.name existant: $current_name"
    fi

    if [[ -z "$current_email" ]]; then
        read -rp "Git user.email: " git_email
        if [[ -n "$git_email" ]]; then
            git config --global user.email "$git_email"
            log_success "user.email configuré: $git_email"
        fi
    else
        log_info "user.email existant: $current_email"
    fi
}
