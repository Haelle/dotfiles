#!/usr/bin/env bash
# packages.sh - Package mapping and installation for apt/pacman

# Package name mapping: logical_name -> "apt_name|pacman_name"
# Use "-" to skip a package on that platform
declare -A PKG_MAP=(
    [zsh]="zsh|zsh"
    [tmux]="tmux|tmux"
    [vim]="vim|vim"
    [git]="git|git"
    [git-delta]="git-delta|git-delta"
    [fzf]="fzf|fzf"
    [ripgrep]="ripgrep|ripgrep"
    [fd]="fd-find|fd"
    [bat]="bat|bat"
    [universal-ctags]="universal-ctags|ctags"
    [curl]="curl|curl"
    [htop]="htop|htop"
    [tree]="tree|tree"
    [jq]="jq|jq"
    [openssh]="openssh-client|openssh"
    [zsh-autosuggestions]="zsh-autosuggestions|zsh-autosuggestions"
    [zsh-syntax-highlighting]="zsh-syntax-highlighting|zsh-syntax-highlighting"
    [neovim]="neovim|neovim"
    [nodejs]="nodejs|nodejs"
    [npm]="npm|npm"
    [python3]="python3|python"
    [pip]="python3-pip|python-pip"
    [unzip]="unzip|unzip"
    [wget]="wget|wget"
)

# Resolve logical package name to distro-specific name
resolve_pkg() {
    local logical="$1"
    local mapping="${PKG_MAP[$logical]:-}"

    if [[ -z "$mapping" ]]; then
        # No mapping found, use logical name as-is
        echo "$logical"
        return
    fi

    local apt_name pacman_name
    apt_name="${mapping%%|*}"
    pacman_name="${mapping##*|}"

    case "$PKG_MGR" in
        apt)    echo "$apt_name" ;;
        pacman) echo "$pacman_name" ;;
    esac
}

# Install a list of logical package names
install_packages() {
    local packages=("$@")
    local resolved=()

    for pkg in "${packages[@]}"; do
        local name
        name="$(resolve_pkg "$pkg")"
        if [[ "$name" != "-" ]]; then
            resolved+=("$name")
        fi
    done

    if [[ ${#resolved[@]} -eq 0 ]]; then
        info "No packages to install"
        return
    fi

    header "Installing packages"
    info "Packages: ${resolved[*]}"

    case "$PKG_MGR" in
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y -qq "${resolved[@]}"
            ;;
        pacman)
            sudo pacman -Syu --noconfirm --needed "${resolved[@]}"
            ;;
    esac

    success "Packages installed"
}

# Install starship prompt
install_starship() {
    if command -v starship &>/dev/null; then
        info "Starship already installed"
        return
    fi

    header "Installing Starship prompt"

    case "$PKG_MGR" in
        pacman)
            sudo pacman -S --noconfirm --needed starship
            ;;
        apt)
            # Try apt first (available on newer Ubuntu), fall back to snap
            if apt-cache show starship &>/dev/null 2>&1; then
                sudo apt-get install -y -qq starship
            elif command -v snap &>/dev/null; then
                sudo snap install starship
            else
                # Last resort: curl installer (works offline if binary is cached)
                warn "starship not in apt/snap, trying curl installer"
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
    esac

    success "Starship installed"
}

# Install starship via curl (online mode)
install_starship_online() {
    if command -v starship &>/dev/null; then
        info "Starship already installed"
        return
    fi

    header "Installing Starship prompt"

    case "$PKG_MGR" in
        pacman)
            sudo pacman -S --noconfirm --needed starship
            ;;
        apt)
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            ;;
    esac

    success "Starship installed"
}

# Install Oh My ZSH (online mode)
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        info "Oh My ZSH already installed"
        return
    fi

    header "Installing Oh My ZSH"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My ZSH installed"

    # Clone custom plugins
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
        success "Cloned zsh-autosuggestions"
    fi

    if [[ ! -d "$custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"
        success "Cloned zsh-syntax-highlighting"
    fi
}
