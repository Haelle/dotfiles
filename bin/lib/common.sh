#!/usr/bin/env bash
# common.sh - Foundation utilities for dotfiles installers

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Globals
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# --- Logging ---

info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$*"
}

success() {
    printf "${GREEN}[OK]${NC} %s\n" "$*"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$*"
}

error() {
    printf "${RED}[ERROR]${NC} %s\n" "$*" >&2
}

header() {
    printf "\n${BOLD}${BLUE}==> %s${NC}\n" "$*"
}

# --- Distro detection ---

detect_distro() {
    if [[ ! -f /etc/os-release ]]; then
        error "Cannot detect distribution: /etc/os-release not found"
        exit 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    case "${ID:-}" in
        ubuntu|debian)
            DISTRO="ubuntu"
            PKG_MGR="apt"
            ;;
        arch|cachyos)
            DISTRO="arch"
            PKG_MGR="pacman"
            ;;
        *)
            # Check ID_LIKE for derivatives
            case "${ID_LIKE:-}" in
                *ubuntu*|*debian*)
                    DISTRO="ubuntu"
                    PKG_MGR="apt"
                    ;;
                *arch*)
                    DISTRO="arch"
                    PKG_MGR="pacman"
                    ;;
                *)
                    error "Unsupported distribution: ${ID:-unknown}"
                    exit 1
                    ;;
            esac
            ;;
    esac

    success "Detected distro: ${ID} (family: ${DISTRO}, pkg manager: ${PKG_MGR})"
    export DISTRO PKG_MGR
}

# --- Backup ---

backup_file() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        local rel_path="${target#$HOME/}"
        local backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        cp -a "$target" "$backup_path"
        info "Backed up $target → $backup_path"
    fi
}

# --- Symlink ---

make_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        warn "Source does not exist: $source"
        return 1
    fi

    # Backup existing file (not symlink)
    backup_file "$target"

    # Remove existing symlink or file
    if [[ -L "$target" || -e "$target" ]]; then
        rm -rf "$target"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    ln -sf "$source" "$target"
    success "Linked $target → $source"
}

# --- Git identity ---

setup_git_identity() {
    local git_local="$HOME/.gitconfig.local"

    if [[ -f "$git_local" ]]; then
        info "Git identity already configured in $git_local"
        return
    fi

    header "Git Identity Setup"
    echo "This will be stored in ~/.gitconfig.local (not versioned)"
    echo

    read -rp "Git user.name: " git_name
    read -rp "Git user.email: " git_email

    if [[ -z "$git_name" || -z "$git_email" ]]; then
        warn "Skipping git identity setup (empty input)"
        return
    fi

    cat > "$git_local" <<EOF
[user]
    name = $git_name
    email = $git_email
EOF

    success "Created $git_local"
}

# --- Shell change ---

propose_zsh() {
    local zsh_path
    zsh_path="$(which zsh 2>/dev/null || true)"

    if [[ -z "$zsh_path" ]]; then
        warn "zsh not found in PATH"
        return
    fi

    if [[ "$SHELL" == "$zsh_path" ]]; then
        info "Default shell is already zsh"
        return
    fi

    echo
    read -rp "Change default shell to zsh? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        chsh -s "$zsh_path"
        success "Default shell changed to $zsh_path"
    else
        info "Skipped shell change. Run: chsh -s $zsh_path"
    fi
}

# --- Summary ---

print_summary() {
    local mode="$1"
    echo
    printf "${BOLD}${GREEN}%s${NC}\n" "════════════════════════════════════════"
    printf "${BOLD}${GREEN}  Dotfiles installed! (mode: %s)${NC}\n" "$mode"
    printf "${BOLD}${GREEN}%s${NC}\n" "════════════════════════════════════════"
    echo
    if [[ -d "$BACKUP_DIR" ]]; then
        info "Backups saved to: $BACKUP_DIR"
    fi
    info "Git identity: ~/.gitconfig.local"
    info "Restart your shell or run: exec zsh"
    echo
}
