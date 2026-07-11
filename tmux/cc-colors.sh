#!/usr/bin/env bash
# shellcheck disable=SC2034  # BAR/LC/RC/PBG/PFG/PBOLD sont lus par les scripts qui sourcent
# cc-colors.sh — palette TokyoNight Night + décision de couleur d'une pilule selon
# l'état Claude. Sourcé par cc-bar.sh (sessions) et cc-tabs.sh (onglets) pour qu'ils
# restent visuellement cohérents. Ne s'exécute pas seul.

BAR="#16161e"        # fond de la barre (doit matcher status-style dans tmux.conf)
LC=$'\ue0b6'; RC=$'\ue0b4'   # demi-cercles powerline gauche/droite (Nerd Font)

# cc_pill_colors <focus:0|1> <state> <pulse:0|1>
# Renseigne PBG / PFG / PBOLD selon la priorité focus > waiting > done > idle.
cc_pill_colors() {
    PBOLD=""
    if [ "$1" = 1 ]; then
        PBG="#7aa2f7"; PFG="$BAR"; PBOLD=",bold"              # focus : bleu
    elif [ "$2" = "waiting" ]; then
        [ "$3" -eq 0 ] && PBG="#f7768e" || PBG="#db4b4b"      # waiting : rouge clignotant
        PFG="$BAR"
    elif [ "$2" = "done" ]; then
        PBG="#9ece6a"; PFG="$BAR"                             # done : vert
    else
        PBG="#292e42"; PFG="#a9b1d6"                          # idle : bleu-gris doux
    fi
}

# cc_state_emoji <state> — imprime l'emoji de préfixe (rien si aucun).
cc_state_emoji() {
    case "$1" in
        waiting) printf '🪇 ' ;;   # attente : maracas
        done)    printf '🤖 ' ;;   # fini    : robot
    esac
}
