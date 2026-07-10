#!/usr/bin/env bash
# cc-bar.sh — rendu de status-left : liste toutes les sessions tmux sous forme de
# pilules ARRONDIES (demi-cercles powerline), colorées selon l'état Claude agrégé
# de chaque session (@cc_state, scope window). Palette TokyoNight Night.
#
# État agrégé d'une session = priorité waiting > done > idle, calculé en
# scannant les @cc_state de ses fenêtres (seule la fenêtre `claude` le porte).
#   focus   -> bleu           (session courante, texte sombre gras)
#   waiting -> rouge clignotant (Claude attend une intervention)
#   done    -> vert           (Claude a fini son tour)
#   idle    -> bleu-gris doux  (running / rien à signaler)
# Nerd Font requise pour les bouts arrondis (MesloLGS NF etc.).

cur="${1:-$(tmux display -p '#S' 2>/dev/null)}"   # session courante (passée par tmux)
pulse=$(( $(date +%s) % 2 ))   # parité 1s : sert à faire CLIGNOTER le FOND (pas juste le texte)

BAR="#16161e"        # fond de la barre (TokyoNight bg_dark) — doit matcher status-style
LC=""; RC=""       # demi-cercles powerline : bouts de pilule gauche / droite

out=""
while IFS= read -r sess; do
    state="idle"
    while IFS= read -r ws; do
        case "$ws" in
            waiting) state="waiting"; break ;;   # priorité max, on arrête
            done)    state="done" ;;             # mémorise, cherche encore un waiting
        esac
    done < <(tmux list-windows -t "$sess" -F '#{@cc_state}' 2>/dev/null)

    bold=""
    if [ "$sess" = "$cur" ]; then
        pbg="#7aa2f7"; pfg="$BAR"; bold=",bold"                 # focus : bleu
    elif [ "$state" = "waiting" ]; then
        [ "$pulse" -eq 0 ] && pbg="#f7768e" || pbg="#db4b4b"    # waiting : rouge clignotant
        pfg="$BAR"
    elif [ "$state" = "done" ]; then
        pbg="#9ece6a"; pfg="$BAR"                               # done : vert
    else
        pbg="#292e42"; pfg="#a9b1d6"                            # idle : bleu-gris doux
    fi

    marker=""; [ "$sess" = "$cur" ] && marker="🎯 "          # session courante
    bot=""; case "$state" in
        waiting) bot="🪇 " ;;   # attente : maracas
        done)    bot="🤖 " ;;   # fini    : robot
    esac
    label=" ${marker}${bot}${sess} "
    # gouttière (fond barre) avant chaque session sauf la 1re, pour aérer
    [ -n "$out" ] && out="${out}#[default] "
    # pilule arrondie : demi-cercle gauche (couleur pilule sur fond barre) + corps + demi-cercle droit
    pill="#[fg=${pbg},bg=${BAR}]${LC}#[bg=${pbg},fg=${pfg}${bold}]${label}#[fg=${pbg},bg=${BAR}]${RC}"
    # range=user|NAME : rend la session cliquable. tmux n'a pas de type `session`,
    # on passe par `user` -> #{mouse_status_range} vaut alors le nom de session.
    out="${out}#[range=user|${sess}]${pill}#[norange]#[default]"
done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)

printf '%s' "$out"
