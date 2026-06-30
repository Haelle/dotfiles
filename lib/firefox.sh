#!/usr/bin/env bash
# Installation de Firefox en .deb Mozilla (et non snap)
#
# Cause du retour intempestif au snap : unattended-upgrades réinstalle le stub
# Ubuntu `firefox` (epoch 1:) qu'apt voit "plus récent" que le .deb. Un pin +1000
# sur Mozilla ne suffit pas : il faut un pin -1 qui INTERDIT le stub.
# Idempotent.

FIREFOX_KEYRING=/etc/apt/keyrings/packages.mozilla.org.asc
FIREFOX_SOURCE=/etc/apt/sources.list.d/mozilla.list
FIREFOX_PREF=/etc/apt/preferences.d/mozilla

install_firefox() {
    log_header "Firefox"

    if ! command -v apt &>/dev/null; then
        log_warning "Système non basé sur apt, module Firefox ignoré"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_dry "Installation de la clé et du dépôt Mozilla"
        log_dry "Pinning : Mozilla=1000, stub Ubuntu=-1"
        log_dry "Installation du .deb Mozilla et suppression du snap Firefox"
        return
    fi

    # 1. Clé de signature Mozilla
    if [[ -s "$FIREFOX_KEYRING" ]]; then
        log_info "Clé Mozilla déjà présente"
    else
        log_info "Installation de la clé Mozilla"
        sudo install -d /etc/apt/keyrings
        wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg \
            | sudo tee "$FIREFOX_KEYRING" >/dev/null
    fi

    # 2. Dépôt Mozilla
    local expected_src="deb [signed-by=$FIREFOX_KEYRING] https://packages.mozilla.org/apt mozilla main"
    if [[ -f "$FIREFOX_SOURCE" ]] && grep -qF "$expected_src" "$FIREFOX_SOURCE"; then
        log_info "Dépôt Mozilla déjà configuré"
    else
        log_info "Configuration du dépôt Mozilla"
        echo "$expected_src" | sudo tee "$FIREFOX_SOURCE" >/dev/null
    fi

    # 3. Pinning : préférer Mozilla ET interdire le stub Ubuntu
    log_info "Écriture du pinning ($FIREFOX_PREF)"
    sudo tee "$FIREFOX_PREF" >/dev/null <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

    # 4. Installation du .deb Mozilla
    log_info "Installation de Firefox (.deb Mozilla)"
    sudo apt update -qq
    sudo apt install -y --allow-downgrades firefox

    # 5. Suppression du snap s'il existe
    if command -v snap &>/dev/null && snap list firefox &>/dev/null; then
        log_info "Suppression du snap Firefox"
        sudo snap remove --purge firefox
    fi

    # 6. Vérification
    local installed
    installed=$(apt-cache policy firefox | awk '/Installé|Installed/{print $2}')
    if [[ "$installed" == *snap* || "$installed" == 1:* ]]; then
        log_error "Le paquet installé est encore le stub : $installed"
        return 1
    fi
    log_success "Firefox installé en .deb : $installed"
}
