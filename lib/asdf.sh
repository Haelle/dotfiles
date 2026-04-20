#!/usr/bin/env bash
# Installation d'asdf (gestionnaire de runtimes) et Node.js

# Versions épinglées (changer ici pour mettre à jour tous les PC)
NODE_VERSION="24.14.0"

ASDF_BIN="$HOME/.local/bin/asdf"
ASDF_DATA_DIR="$HOME/.asdf"

install_asdf_bin() {
    log_header "asdf"

    if command -v asdf &>/dev/null; then
        log_info "asdf déjà installé ($(asdf --version))"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Installation d'asdf depuis GitHub releases"
        return
    fi

    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) log_error "Architecture non supportée: $(uname -m)"; return 1 ;;
    esac

    local asdf_version
    asdf_version=$(curl -sL https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name')
    log_info "Installation d'asdf ${asdf_version}..."

    mkdir -p "$HOME/.local/bin"
    local tmp_tar
    tmp_tar=$(mktemp /tmp/asdf-XXXXXX.tar.gz)
    curl -sL -o "$tmp_tar" \
        "https://github.com/asdf-vm/asdf/releases/download/${asdf_version}/asdf-${asdf_version}-linux-${arch}.tar.gz"
    tar xz -C "$HOME/.local/bin" -f "$tmp_tar" asdf
    rm "$tmp_tar"

    # Disponible immédiatement pour la suite du script
    export PATH="$HOME/.local/bin:$ASDF_DATA_DIR/shims:$PATH"
    export ASDF_DATA_DIR

    log_success "asdf installé ($(asdf --version))"
}

install_node_via_asdf() {
    log_header "Node.js (via asdf)"

    if ! command -v asdf &>/dev/null; then
        log_warning "asdf non disponible, skip de Node.js"
        return 1
    fi

    if asdf list nodejs &>/dev/null; then
        log_info "Node.js déjà installé: $(asdf current nodejs 2>/dev/null | awk '{print $2}')"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "asdf plugin add nodejs && asdf install nodejs ${NODE_VERSION} && asdf set -u nodejs ${NODE_VERSION}"
        return
    fi

    log_info "Ajout du plugin nodejs..."
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git 2>/dev/null || true

    log_info "Installation de Node.js ${NODE_VERSION}..."
    asdf install nodejs "$NODE_VERSION" && asdf set -u nodejs "$NODE_VERSION" && asdf reshim nodejs \
        && log_success "Node.js installé: $(asdf exec node --version) (npm $(asdf exec npm --version))" \
        || log_warning "Installation Node.js échouée"
}

install_asdf() {
    install_asdf_bin
    install_node_via_asdf
}
