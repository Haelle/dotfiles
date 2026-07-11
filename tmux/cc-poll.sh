#!/usr/bin/env bash
# cc-poll.sh — réconcilie l'état waiting -> running en LISANT L'ÉCRAN (approche herdr).
#
# Les hooks Claude ne couvrent pas la fenêtre « repris mais pas encore d'outil » :
# après une Notification (waiting/rouge), rien ne repasse en running tant que Claude
# n'a pas atteint son 1er PreToolUse — il peut réfléchir/streamer plusieurs secondes.
# Or à l'écran le spinner s'anime déjà. On capture le pane actif des fenêtres waiting :
# si le spinner de travail est visible, la fenêtre est en fait running.
#
# Spinner Claude (TUI plein écran) = verbe + ellipse + timer, ex "Zigzagging… (59s · …)".
# Lancé à chaque tick comme #() autonome depuis status-format (voir tmux.conf).

changed=0
while IFS=$'\t' read -r win state; do
    [ "$state" = "waiting" ] || continue
    if tmux capture-pane -p -t "$win" 2>/dev/null | grep -qE '…[[:space:]]*\([0-9]'; then
        tmux set -w -t "$win" @cc_state running 2>/dev/null && changed=1
    fi
done < <(tmux list-windows -a -F '#{window_id}	#{@cc_state}' 2>/dev/null)

[ "$changed" = 1 ] && tmux refresh-client -S 2>/dev/null
exit 0
