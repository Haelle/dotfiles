#!/usr/bin/env bash
# Installation de NeoVim via asdf + configuration kickstart.nvim

install_neovim() {
    log_header "NeoVim"

    local nvim_config="$HOME/.config/nvim"

    # tree-sitter-cli n'est pas dispo via apt sur Ubuntu → install via cargo
    if command -v apt &>/dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y (si cargo absent)"
            log_dry "cargo install tree-sitter-cli"
        else
            if ! command -v cargo &>/dev/null; then
                log_info "Installation de Rust/Cargo via rustup..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && log_success "Rust/Cargo installé" || { log_warning "Installation Rust/Cargo échouée"; }
                source "$HOME/.cargo/env" 2>/dev/null || true
            fi
            log_info "Installation de tree-sitter-cli via cargo..."
            cargo install tree-sitter-cli && log_success "tree-sitter-cli installé" || log_warning "Installation tree-sitter-cli échouée"
        fi
    fi

    # Installation nvm + Node.js 20 (requis par certains LSP/plugins)
    local NVM_DIR="$HOME/.nvm"
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash (si nvm absent)"
        log_dry "nvm install 20"
    else
        if [[ ! -d "$NVM_DIR" ]]; then
            log_info "Installation de nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && log_success "nvm installé" || { log_warning "Installation nvm échouée"; }
        fi
        # Charger nvm dans le shell courant
        export NVM_DIR
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        if ! nvm ls 20 &>/dev/null; then
            log_info "Installation de Node.js 20 via nvm..."
            nvm install 20 && log_success "Node.js 20 installé" || log_warning "Installation Node.js 20 échouée"
        else
            log_info "Node.js 20 déjà installé"
        fi
    fi

    # Installation asdf si absent
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "git clone https://github.com/asdf-vm/asdf.git ~/.asdf (si asdf absent)"
    else
        if [[ ! -d "$HOME/.asdf" ]]; then
            log_info "Installation de asdf..."
            git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.16.7 && log_success "asdf installé" || { log_warning "Installation asdf échouée"; }
        fi
        # Charger asdf dans le shell courant
        source "$HOME/.asdf/asdf.sh" 2>/dev/null || true
    fi

    # Backup de ~/.config/nvim si existant
    if [[ -e "$nvim_config" ]]; then
        backup_file "$nvim_config" "$BACKUP_DIR/nvim"
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "rm -rf $nvim_config"
        else
            rm -rf "$nvim_config"
        fi
    fi

    # Clone kickstart.nvim
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "git clone git@github.com:Haelle/kickstart.nvim.git $nvim_config"
    else
        log_info "Clone de kickstart.nvim..."
        git clone git@github.com:Haelle/kickstart.nvim.git "$nvim_config" && log_success "kickstart.nvim cloné dans $nvim_config" || log_warning "Clone kickstart.nvim échoué"
    fi

    # Installation quadlet-lsp (LSP pour fichiers Podman Quadlet)
    if command -v quadlet-lsp &>/dev/null; then
        log_info "quadlet-lsp déjà installé"
    elif [[ "$DRY_RUN" == true ]]; then
        log_dry "Installation de quadlet-lsp depuis GitHub releases"
    else
        log_info "Installation de quadlet-lsp..."
        local ql_version ql_tmp
        ql_version=$(curl -s https://api.github.com/repos/onlyati/quadlet-lsp/releases/latest | grep -Po '"tag_name": "\K[^"]+')
        ql_tmp=$(mktemp -d)
        if command -v apt &>/dev/null; then
            curl -fsSL "https://github.com/onlyati/quadlet-lsp/releases/download/${ql_version}/quadlet-lsp_${ql_version#v}_linux_amd64.deb" -o "$ql_tmp/quadlet-lsp.deb" \
                && sudo dpkg -i "$ql_tmp/quadlet-lsp.deb" \
                && log_success "quadlet-lsp installé via .deb" \
                || log_warning "Installation quadlet-lsp échouée"
        elif command -v pacman &>/dev/null; then
            curl -fsSL "https://github.com/onlyati/quadlet-lsp/releases/download/${ql_version}/quadlet-lsp-${ql_version#v}-linux-amd64.tar.gz" -o "$ql_tmp/quadlet-lsp.tar.gz" \
                && sudo tar -xzf "$ql_tmp/quadlet-lsp.tar.gz" -C /usr/local/bin/ \
                && log_success "quadlet-lsp installé dans /usr/local/bin" \
                || log_warning "Installation quadlet-lsp échouée"
        fi
        rm -rf "$ql_tmp"
    fi

    # Installation NeoVim via asdf
    local tool_versions="$HOME/.tool-versions"
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "asdf plugin add neovim"
        log_dry "asdf install neovim stable"
        log_dry "Ajout de 'neovim stable' dans $tool_versions"
        log_dry "asdf reshim neovim"
    else
        log_info "Installation de NeoVim via asdf..."
        asdf plugin add neovim || true
        asdf install neovim stable && log_success "NeoVim stable installé via asdf" || { log_warning "Installation NeoVim via asdf échouée"; return; }
        if ! grep -q "^neovim " "$tool_versions" 2>/dev/null; then
            echo "neovim stable" >> "$tool_versions"
            log_success "neovim stable ajouté dans $tool_versions"
        else
            log_info "neovim déjà présent dans $tool_versions"
        fi
        asdf reshim neovim
    fi
}
