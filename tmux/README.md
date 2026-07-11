# Dashboard tmux des sessions Claude

Barre de statut (en haut, 4 lignes) qui colore chaque **onglet** et chaque **session** selon l'état du Claude qui y tourne, pour piloter plusieurs agents en parallèle d'un coup d'œil.

## Modèle d'état

Chaque fenêtre porte une variable tmux `@cc_state` (scope window, posée sur la fenêtre où tourne Claude) :

| état | couleur | signification |
|------|---------|---------------|
| `running` | gris (bleu-gris doux) | Claude travaille |
| `waiting` | rouge clignotant | Claude attend une intervention |
| `done` | vert | Claude a fini son tour |
| *(absent)* | gris | idle / pas de Claude |

La session (dans `cc-bar`) agrège ses fenêtres par priorité `waiting > done > idle`. Le focus (onglet actif / session courante) prime sur tout → bleu. Palette et décision de couleur centralisées dans [`cc-colors.sh`](cc-colors.sh) (`cc_pill_colors`), sourcé par `cc-bar` et `cc-tabs` pour qu'ils ne divergent pas.

## Comment `@cc_state` est mis à jour — deux mécanismes

**1. Hooks Claude Code** (event-driven, instantané) — dans [`../claude/settings.json`](../claude/settings.json) :

- `UserPromptSubmit` / `PreToolUse` → `running`
- `Notification` → `waiting` (sauf si déjà `done`)
- `Stop` → `done`

Chaque hook est gardé par `[ -n "$TMUX_PANE" ]` (**gotcha** : `tmux set -w -t ""` cible la fenêtre *active* du serveur → empoisonne une session sans rapport) et appelle `tmux refresh-client -S` pour forcer le redraw immédiat (sinon latence jusqu'au prochain tick).

**2. Poll par lecture d'écran** ([`cc-poll.sh`](cc-poll.sh)) — comble le trou que les hooks ne couvrent pas.

Aucun hook ne se déclenche quand Claude **reprend à réfléchir/streamer** après un `waiting`, tant qu'il n'a pas atteint son 1er `PreToolUse` — le rouge s'attarde plusieurs secondes. Or à l'écran le spinner s'anime déjà. Le poll (lancé chaque tick via `status-format[1]`, cf. [`tmux.conf`](tmux.conf)) fait `capture-pane` sur les fenêtres `waiting` et, s'il voit le spinner, repasse `running`.

Approche empruntée à [herdr](https://github.com/ogulcancelik/herdr) (« agent state detection via terminal tail pattern matching »), sauf que tmux **est** déjà le multiplexeur : `capture-pane -p` donne le même « terminal tail » sans wrapper le PTY, et lit l'écran alterné (TUI plein écran de Claude) même sur un pane non visible.

Détection = regex `…\s*\([0-9]` (verbe en cours + ellipse + timer, ex `Zigzagging… (59s · ↓ 3.2k tokens)`). **Gotcha** : fragile aux changements de TUI Claude entre versions (herdr paie ça avec un manifest versionné à distance ; ici la regex est en dur). Le poll ne fait **que** `waiting→running`.

## Rendu

- [`cc-bar.sh`](cc-bar.sh) — `status-format[0]`, gauche : liste des sessions en pilules arrondies. Marqueur `🎯` = session courante.
- [`cc-tabs.sh`](cc-tabs.sh) — `status-format[2]` : onglets de la session courante, pleine largeur (chaque onglet = largeur/N), pilules arrondies avec calcul de largeur strict.
- Clignotement : `pulse=$(date +%s % 2)` alterne la couleur de **fond** à chaque seconde, rafraîchi par `status-interval 1` (plancher tmux).
- Emoji de préfixe (`🪇` waiting / `🤖` done) via `cc_state_emoji`. **Gotcha** largeur : un emoji = 2 colonnes mais 1 char en bash `${#}` → `extra=1` dans le calcul de `cc-tabs`.

**Gotchas tmux** :
- Demi-cercles powerline définis via `$''`/`$''` (Nerd Font) dans `cc-colors.sh` — échappement unicode pour survivre aux éditions.
- Pas de type de range `session` en tmux : sessions cliquables via `range=user|NAME` → `#{mouse_status_range}` vaut le nom (dispatch dans `tmux.conf`, binding `MouseDown1Status`).

## Raccourcis

`prefix + C-w` saute à la 1re session `waiting` ([`cc-goto.sh`](cc-goto.sh)). Autres binds dans [`tmux.conf`](tmux.conf) ; aide-mémoire via `prefix + C-h` ([`tmux-cheatsheet.sh`](tmux-cheatsheet.sh)).

## Déploiement

Symlinks posés par [`../lib/tmux.sh`](../lib/tmux.sh) (`install_tmux`) vers `~/.config/tmux/` et `~/.tmux.conf`.
