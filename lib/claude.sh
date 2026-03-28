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

    # Skills (depuis Jeffallan/claude-skills)
    create_symlink "$DOTFILES_DIR/claude/skills" "$claude_home/skills" "claude-skills"

    # Commands custom
    create_symlink "$DOTFILES_DIR/claude/commands" "$claude_home/commands" "claude-commands"

    # CLAUDE.md global
    create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$claude_home/CLAUDE.md" "claude-md"

    # Settings
    create_symlink "$DOTFILES_DIR/claude/managed-settings.json" "$claude_home/managed-settings.json" "claude-settings"

    # Statusline
    create_symlink "$DOTFILES_DIR/claude/statusline-command.sh" "$claude_home/statusline-command.sh" "claude-statusline"
}

install_claude() {
    install_claude_bin
    install_claude_conf
}
