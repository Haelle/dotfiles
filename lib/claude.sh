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

install_claude_conf() {
    log_header "Claude Code (configuration)"

    local claude_home="$HOME/.claude"

    # Commands custom
    create_symlink "$DOTFILES_DIR/claude/commands" "$claude_home/commands" "claude-commands"

    # CLAUDE.md global
    create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$claude_home/CLAUDE.md" "claude-md"

    # Settings (skills, plugins, LSP, permissions, statusline)
    create_symlink "$DOTFILES_DIR/claude/settings.json" "$claude_home/settings.json" "claude-settings"

    # Statusline
    create_symlink "$DOTFILES_DIR/claude/statusline-command.sh" "$claude_home/statusline-command.sh" "claude-statusline"
}

install_claude_deps() {
    log_header "Claude Code (dépendances)"

    local npm_packages=(ccusage typescript-language-server typescript pyright bash-language-server yaml-language-server)

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "npm install -g ${npm_packages[*]}"
    else
        log_info "Installation des paquets npm..."
        npm install -g "${npm_packages[@]}"
    fi

    # terraform-ls (AUR uniquement, installé via paru)
    if command -v terraform-ls &>/dev/null; then
        log_info "terraform-ls déjà installé"
    elif ! command -v paru &>/dev/null; then
        log_warning "paru non trouvé, impossible d'installer terraform-ls (AUR)"
    elif [[ "$DRY_RUN" == true ]]; then
        log_dry "paru -S terraform-ls"
    else
        log_info "Installation de terraform-ls depuis l'AUR..."
        paru -S --noconfirm --skipreview terraform-ls
    fi

    # lua-language-server (install depuis GitHub releases)
    local luals_dir="$HOME/.local/lib/lua-language-server"
    if command -v lua-language-server &>/dev/null || [[ -x "$luals_dir/bin/lua-language-server" ]]; then
        log_info "lua-language-server déjà installé"
    elif [[ "$DRY_RUN" == true ]]; then
        log_dry "installer lua-language-server depuis GitHub releases"
    else
        local luals_version
        luals_version=$(curl -sL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name')
        log_info "Installation de lua-language-server ${luals_version}..."
        mkdir -p "$luals_dir"
        curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/${luals_version}/lua-language-server-${luals_version}-linux-x64.tar.gz" \
            | tar xz -C "$luals_dir"
        ln -sf "$luals_dir/bin/lua-language-server" "$HOME/.local/bin/lua-language-server"
    fi
}

install_claude() {
    install_claude_bin
    install_claude_deps
    install_claude_conf
}
