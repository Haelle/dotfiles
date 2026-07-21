#!/bin/sh
# docker sandbox recrée ~/.claude/settings.json à chaque create et ignore le
# fichier baké dans le template. On merge notre overlay juste avant de lancer
# claude : nos clés (statusLine, plugins, permissions) s'ajoutent au seed docker.
target="$HOME/.claude/settings.json"
overlay="$HOME/.claude-sandbox-settings.json"

[ -f "$target" ] || echo '{}' > "$target"

if [ -f "$overlay" ] && command -v jq >/dev/null 2>&1; then
  tmp=$(mktemp)
  if jq -s '.[0] * .[1]' "$target" "$overlay" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$target"
  else
    rm -f "$tmp"
  fi
fi

exec "$HOME/.local/bin/claude.real" "$@"
