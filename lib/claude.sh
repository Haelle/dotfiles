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

    # asdf + Node.js (factorisé dans lib/asdf.sh) — requis pour npm et MCP svelte
    install_asdf_bin
    install_node_via_asdf

    local npm_packages=(ccusage claude-spp typescript-language-server typescript pyright bash-language-server yaml-language-server)

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "npm install -g ${npm_packages[*]}"
    elif command -v npm &>/dev/null; then
        log_info "Installation des paquets npm..."
        npm install -g "${npm_packages[@]}"
    else
        log_warning "npm introuvable, skip des paquets npm"
    fi

    # terraform-ls
    if command -v terraform-ls &>/dev/null; then
        log_info "terraform-ls déjà installé"
    elif command -v paru &>/dev/null; then
        # Arch: AUR via paru
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "paru -S terraform-ls"
        else
            log_info "Installation de terraform-ls depuis l'AUR..."
            paru -S --noconfirm --skipreview terraform-ls
        fi
    elif command -v apt &>/dev/null; then
        # Ubuntu/Debian: nécessite le dépôt HashiCorp
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "ajout du dépôt HashiCorp + apt install terraform-ls"
        else
            log_info "Ajout du dépôt HashiCorp..."
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
                | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
            sudo apt update -qq
            sudo apt install -y terraform-ls
        fi
    else
        log_warning "Impossible d'installer terraform-ls: ni paru ni apt disponible"
    fi

    # OmniSharp C# LSP (install depuis GitHub releases, méthode Mason)
    local omnisharp_dir="$HOME/.local/lib/omnisharp"
    if [[ -f "$omnisharp_dir/OmniSharp.dll" ]]; then
        log_info "OmniSharp déjà installé"
    elif [[ "$DRY_RUN" == true ]]; then
        log_dry "installer OmniSharp depuis GitHub releases"
    else
        local omnisharp_version
        omnisharp_version=$(curl -sL https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases/latest | jq -r '.tag_name')
        log_info "Installation de OmniSharp ${omnisharp_version}..."
        mkdir -p "$omnisharp_dir"
        local tmp_zip
        tmp_zip=$(mktemp /tmp/omnisharp-XXXXXX.zip)
        curl -sL -o "$tmp_zip" "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/${omnisharp_version}/omnisharp-linux-x64-net6.0.zip"
        unzip -qo "$tmp_zip" -d "$omnisharp_dir"
        rm "$tmp_zip"
        # Wrapper script: lance via dotnet runtime (comme Mason)
        cat > "$HOME/.local/bin/OmniSharp" <<WRAPPER
#!/usr/bin/env bash
exec dotnet "$omnisharp_dir/OmniSharp.dll" "\$@"
WRAPPER
        chmod +x "$HOME/.local/bin/OmniSharp"
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
