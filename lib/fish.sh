#!/usr/bin/env bash
# Installation de la configuration Fish

install_fish() {
    log_header "Fish Shell"

    local fish_source="$DOTFILES_DIR/fish"
    local fish_target="$HOME/.config/fish"

    # Symlink config.fish
    create_symlink "$fish_source/config.fish" "$fish_target/config.fish" "fish/config.fish"

    # Symlink conf.d directory contents
    if [[ -d "$fish_source/conf.d" ]]; then
        mkdir -p "$fish_target/conf.d"
        for file in "$fish_source/conf.d"/*.fish; do
            if [[ -f "$file" ]]; then
                local filename
                filename=$(basename "$file")
                create_symlink "$file" "$fish_target/conf.d/$filename" "fish/conf.d/$filename"
            fi
        done
    fi

    # Symlink functions directory contents
    if [[ -d "$fish_source/functions" ]]; then
        mkdir -p "$fish_target/functions"
        for file in "$fish_source/functions"/*.fish; do
            if [[ -f "$file" ]]; then
                local filename
                filename=$(basename "$file")
                create_symlink "$file" "$fish_target/functions/$filename" "fish/functions/$filename"
            fi
        done
    fi

    # Symlink fish_plugins (liste des plugins Fisher)
    if [[ -f "$fish_source/fish_plugins" ]]; then
        create_symlink "$fish_source/fish_plugins" "$fish_target/fish_plugins" "fish/fish_plugins"
    fi

    # Post-installation: Fisher et plugins
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Installation Fisher + plugins depuis fish_plugins"
        log_dry "Ajout de fish à /etc/shells si nécessaire"
        log_dry "chsh -s $(which fish) pour définir Fish comme shell par défaut"
    else
        if command -v fish &> /dev/null; then
            log_info "Installation de Fisher et des plugins..."
            fish -c '
                if not functions -q fisher
                    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
                    fisher install jorgebucaran/fisher
                end
                fisher update
            ' 2>/dev/null && log_success "Fisher et plugins installés" || log_warning "Installation Fisher échouée (vérifiez la connexion)"
            log_info "Run 'tide configure' to finalise installation"

            # Définir Fish comme shell par défaut
            local fish_path
            fish_path=$(which fish)
            if ! grep -q "$fish_path" /etc/shells; then
                log_info "Ajout de $fish_path à /etc/shells..."
                echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
            fi
            if [[ "$SHELL" != "$fish_path" ]]; then
                log_info "Changement du shell par défaut vers Fish..."
                chsh -s "$fish_path" && log_success "Shell par défaut: Fish" || log_warning "chsh échoué (relancer avec sudo si nécessaire)"
            else
                log_success "Fish est déjà le shell par défaut"
            fi
        else
            log_warning "Fish non installé, plugins non configurés"
        fi
    fi
}
