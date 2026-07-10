#!/usr/bin/env bash
# cc-goto.sh — saute à la première session dont une fenêtre est en `waiting`,
# puis sélectionne cette fenêtre (= la fenêtre `claude` qui attend).
# Lié à `prefix + C-w` dans tmux.conf.

target=""
while IFS= read -r sess; do
    while IFS=$'\t' read -r idx state; do
        if [ "$state" = "waiting" ]; then
            target="${sess}:${idx}"
            break 2
        fi
    done < <(tmux list-windows -t "$sess" -F '#{window_index}	#{@cc_state}' 2>/dev/null)
done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null)

if [ -n "$target" ]; then
    tmux switch-client -t "${target%%:*}"
    tmux select-window -t "$target"
else
    tmux display-message "cc: aucune session en attente"
fi
