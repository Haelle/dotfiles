#!/usr/bin/env bash
# Fonctions communes pour l'installation des dotfiles

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles/backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_dry()     { echo -e "${YELLOW}[DRY-RUN]${NC} $1"; }

log_header() {
    echo ""
    echo -e "${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

backup_file() {
    local file="$1"
    local backup_path="$2"

    if [[ -e "$file" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_dry "Backup: $file -> $backup_path"
        else
            mkdir -p "$(dirname "$backup_path")"
            cp -a "$file" "$backup_path"
            log_info "Backup créé: $backup_path"
        fi
        return 0
    fi
    return 1
}

create_symlink() {
    local source="$1"
    local target="$2"
    local backup_name="$3"

    if [[ -e "$target" || -L "$target" ]]; then
        backup_file "$target" "$BACKUP_DIR/$backup_name"
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Symlink: $target -> $source"
    else
        rm -rf "$target"
        mkdir -p "$(dirname "$target")"
        ln -s "$source" "$target"
        log_success "Symlink créé: $target -> $source"
    fi
}
