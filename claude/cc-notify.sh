#!/usr/bin/env bash
# cc-notify.sh — hook Notification de Claude Code : fait poper une notification
# Ubuntu (notify-send) quand un agent attend une intervention.
#
# Silencieux si l'agent est déjà sous tes yeux, c.-à-d. sa fenêtre tmux est la
# fenêtre active d'une session attachée. On notifie donc uniquement quand la
# fenêtre n'est PAS active (autre onglet) ou que la session n'est pas attachée.
# Hors tmux (pas de $TMUX_PANE), on notifie toujours.

message=$(jq -r '.message // "attend une intervention"' 2>/dev/null)
[ -n "$message" ] || message="attend une intervention"

title="Claude Code"
if [ -n "$TMUX_PANE" ]; then
    IFS='|' read -r window_active session_attached session_name \
        < <(tmux display -p -t "$TMUX_PANE" '#{window_active}|#{session_attached}|#S' 2>/dev/null)
    [ "$window_active" = "1" ] && [ "${session_attached:-0}" -ge 1 ] 2>/dev/null && exit 0
    title="🪇 ${session_name:-Claude}"
fi

# -h synchronous : une nouvelle notif remplace la précédente (même tag) au lieu de
# s'empiler ; urgence par défaut -> auto-fermeture (pas de pile qui reste à l'écran).
notify-send -a "Claude Code" -h string:x-canonical-private-synchronous:claude-code \
    "$title" "$message" 2>/dev/null || true
