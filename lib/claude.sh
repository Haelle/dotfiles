#!/usr/bin/env bash
# Installation de la configuration Claude Code

install_claude_bin() {
    log_header "Claude Code (binaire)"

    if command -v claude &>/dev/null; then
        log_info "Claude Code déjà installé"
    elif [[ "$DRY_RUN" == true ]]; then
        log_dry "curl -fsSL https://claude.ai/install.sh | bash"
    else
        log_info "Installation de Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash
    fi
}

# Fusionne notre settings.json minimal dans le live (~/.claude/settings.json).
# Sémantique jq `*` : merge récursif des objets, l'opérande de DROITE gagne
# -> nos clés overrident le live ; les clés absentes de notre fichier (plugins
# ajoutés par Claude, etc.) sont préservées. NB : pour les tableaux, `*` remplace
# (nos hooks/permissions écrasent ceux du live), pas de concaténation.
merge_claude_settings() {
    local repo_settings="$DOTFILES_DIR/claude/settings.json"
    local target="$HOME/.claude/settings.json"

    if ! command -v jq &>/dev/null; then
        log_warning "jq introuvable, impossible de fusionner settings.json (skip)"
        return
    fi

    # Ancien install : settings.json était un symlink vers le dépôt. On le retire
    # pour ne pas réécrire dans le repo à travers le lien.
    if [[ -L "$target" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "rm symlink obsolète: $target"
        else
            rm -f "$target"
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Merge jq: $repo_settings -> $target (nos clés prioritaires, chemin du marketplace réécrit sur $DOTFILES_DIR)"
        return
    fi

    [[ -e "$target" ]] && backup_file "$target" "$BACKUP_DIR/claude-settings"

    mkdir -p "$(dirname "$target")"
    local live_tmp merged_tmp repo_tmp
    live_tmp=$(mktemp)
    merged_tmp=$(mktemp)
    repo_tmp=$(mktemp)
    if [[ -f "$target" ]]; then cp "$target" "$live_tmp"; else echo '{}' > "$live_tmp"; fi

    # Le marketplace local est un chemin absolu : le recalculer sur le clone courant
    jq --arg d "$DOTFILES_DIR" '
        if .extraKnownMarketplaces["local-skills"]
        then .extraKnownMarketplaces["local-skills"].source.path = $d + "/claude/skills"
        else . end' "$repo_settings" > "$repo_tmp"

    if jq -s '.[0] * .[1]' "$live_tmp" "$repo_tmp" > "$merged_tmp"; then
        mv "$merged_tmp" "$target"
        log_success "settings.json fusionné (nos clés prioritaires): $target"
    else
        rm -f "$merged_tmp"
        log_error "Échec du merge jq de settings.json"
    fi
    rm -f "$live_tmp" "$repo_tmp"
}

install_claude_conf() {
    log_header "Claude Code (configuration)"

    local claude_home="$HOME/.claude"

    # Commands custom
    create_symlink "$DOTFILES_DIR/claude/commands" "$claude_home/commands" "claude-commands"

    # CLAUDE.md global
    create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$claude_home/CLAUDE.md" "claude-md"

    # Settings : merge jq plutôt que symlink. Claude Code réécrit settings.json
    # au runtime (plugins, marketplaces machine-specific) — un symlink polluait
    # donc le dépôt. On ne track que le strict minimum et on le fusionne dans le
    # live, nos clés étant prioritaires.
    merge_claude_settings

    # Statusline
    create_symlink "$DOTFILES_DIR/claude/statusline-command.sh" "$claude_home/statusline-command.sh" "claude-statusline"

    # Notification desktop (hook Notification -> notify-send)
    create_symlink "$DOTFILES_DIR/claude/cc-notify.sh" "$claude_home/cc-notify.sh" "claude-cc-notify"
}

install_claude_deps() {
    log_header "Claude Code (dépendances)"

    # asdf + Node.js (factorisé dans lib/asdf.sh) — requis pour npm
    install_asdf_bin
    install_node_via_asdf

    # LSP par dépôt : voir docs/claude-par-projet.md
    local npm_packages=(ccusage bash-language-server yaml-language-server)

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "npm install -g ${npm_packages[*]}"
    elif command -v npm &>/dev/null; then
        log_info "Installation des paquets npm..."
        npm install -g "${npm_packages[@]}"
    else
        log_warning "npm introuvable, skip des paquets npm"
    fi
}

install_claude() {
    install_claude_bin
    install_claude_deps
    install_claude_conf
}
