#!/usr/bin/env bash
# cc-bar.sh — rendu de status-left : liste toutes les sessions tmux sous forme de
# pilules ARRONDIES (demi-cercles powerline), colorées selon l'état Claude agrégé
# de chaque session (@cc_state, scope window). Couleurs : voir cc-colors.sh.
#
# État agrégé d'une session = priorité waiting > done > idle, calculé en scannant
# les @cc_state de ses fenêtres (seule la fenêtre `claude` le porte).
#   focus (session courante) 🎯 · waiting 🪇 rouge clignotant · done 🤖 vert · idle gris
# Nerd Font requise pour les bouts arrondis (MesloLGS NF etc.).

source "${0%/*}/cc-colors.sh"

cur="${1:-$(tmux display -p '#S' 2>/dev/null)}"   # session courante (passée par tmux)
pulse=$(( $(date +%s) % 2 ))                       # parité 1s : fait clignoter le FOND

out=""
while IFS= read -r sess; do
    state="idle"
    while IFS= read -r ws; do
        case "$ws" in
            waiting) state="waiting"; break ;;   # priorité max, on arrête
            done)    state="done" ;;             # mémorise, cherche encore un waiting
        esac
    done < <(tmux list-windows -t "$sess" -F '#{@cc_state}' 2>/dev/null)

    [ "$sess" = "$cur" ] && focus=1 || focus=0
    cc_pill_colors "$focus" "$state" "$pulse"

    marker=""; [ "$focus" = 1 ] && marker="🎯 "
    label=" ${marker}$(cc_state_emoji "$state")${sess} "

    [ -n "$out" ] && out="${out}#[default] "   # gouttière (fond barre) entre sessions
    pill="#[fg=${PBG},bg=${BAR}]${LC}#[bg=${PBG},fg=${PFG}${PBOLD}]${label}#[fg=${PBG},bg=${BAR}]${RC}"
    # range=user|NAME : rend la session cliquable. tmux n'a pas de type `session`,
    # on passe par `user` -> #{mouse_status_range} vaut alors le nom de session.
    out="${out}#[range=user|${sess}]${pill}#[norange]#[default]"
done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)

printf '%s' "$out"
