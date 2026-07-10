#!/usr/bin/env bash
# cc-tabs.sh — rend les onglets de la session courante en PLEINE LARGEUR sous forme
# de pilules ARRONDIES (demi-cercles powerline), réparties équitablement
# (chaque onglet = largeur/N), colorées par @cc_state. Palette TokyoNight Night.
# Utilisé par status-format[2]. Reçoit la largeur du client en $1 (fallback query).
#
#   actif -> bleu   waiting -> rouge clignotant   done -> vert   idle -> bleu-gris
# Nerd Font requise pour les bouts arrondis (MesloLGS NF etc.).

width="$1"
[[ "$width" =~ ^[0-9]+$ ]] || width=$(tmux display -p '#{client_width}' 2>/dev/null)
[[ "$width" =~ ^[0-9]+$ ]] || width=80

sess="${2:-$(tmux display -p '#S' 2>/dev/null)}"   # session courante (passée par tmux)

idxs=(); names=(); actives=(); states=()
while IFS=$'\t' read -r i n a s; do
    idxs+=("$i"); names+=("$n"); actives+=("$a"); states+=("$s")
done < <(tmux list-windows -t "$sess" -F '#{window_index}	#{window_name}	#{window_active}	#{@cc_state}' 2>/dev/null)

n=${#idxs[@]}
[ "$n" -eq 0 ] && exit 0

gut=1                             # largeur de la gouttière entre onglets (fond barre)
gutters=$(( (n - 1) * gut ))
avail=$(( width - gutters ))      # largeur restante pour les onglets eux-mêmes
[ "$avail" -lt "$n" ] && avail=$n # garde-fou fenêtre très étroite
base=$(( avail / n ))
rem=$(( avail - base * n ))       # colonnes restantes à répartir sur les 1ers onglets

gutter="#[default]$(printf '%*s' "$gut" '')"   # espace couleur de fond par défaut
pulse=$(( $(date +%s) % 2 ))   # parité 1s : sert à faire CLIGNOTER le FOND (pas juste le texte)

BAR="#16161e"        # fond de la barre (TokyoNight bg_dark) — doit matcher status-style
LC=""; RC=""       # demi-cercles powerline : bouts de pilule gauche / droite

out=""
for (( k=0; k<n; k++ )); do
    seg=$base
    [ "$k" -lt "$rem" ] && seg=$(( base + 1 ))
    inner=$(( seg - 2 )); (( inner < 1 )) && inner=1   # 2 colonnes réservées aux bouts arrondis

    label="${idxs[k]}:${names[k]}"
    extra=0
    case "${states[k]}" in
        waiting) label="🪇 ${label}"; extra=1 ;;   # attente : maracas (emoji = 2 colonnes, 1 char bash)
        done)    label="🤖 ${label}"; extra=1 ;;   # fini    : robot
    esac
    disp=$(( ${#label} + extra ))                          # largeur d'affichage réelle
    if (( disp > inner )); then                            # tronque pour tenir dans le corps
        cut=$(( inner - extra )); (( cut < 0 )) && cut=0   # garde-fou : jamais de longueur négative
        label="${label:0:cut}"; disp=$(( ${#label} + extra ))
    fi

    pad=$(( inner - disp )); (( pad < 0 )) && pad=0
    left=$(( pad / 2 )); right=$(( pad - left ))
    pad_l=$(printf '%*s' "$left" ''); pad_r=$(printf '%*s' "$right" '')

    bold=""
    if [ "${actives[k]}" = "1" ]; then
        pbg="#7aa2f7"; pfg="$BAR"; bold=",bold"              # onglet actif : bleu
    elif [ "${states[k]}" = "waiting" ]; then
        [ "$pulse" -eq 0 ] && pbg="#f7768e" || pbg="#db4b4b" # waiting : rouge clignotant
        pfg="$BAR"
    elif [ "${states[k]}" = "done" ]; then
        pbg="#9ece6a"; pfg="$BAR"                            # done : vert
    else
        pbg="#292e42"; pfg="#a9b1d6"                         # idle : bleu-gris doux
    fi

    # pilule arrondie : demi-cercle gauche + corps (padding + label) + demi-cercle droit
    pill="#[fg=${pbg},bg=${BAR}]${LC}#[bg=${pbg},fg=${pfg}${bold}]${pad_l}${label}${pad_r}#[fg=${pbg},bg=${BAR}]${RC}"
    # range=window|N : rend le segment cliquable (MouseDown1Status -> select-window)
    out="${out}#[range=window|${idxs[k]}]${pill}#[norange]#[default]"
    [ "$k" -lt $(( n - 1 )) ] && out="${out}${gutter}"   # gouttière sauf après le dernier
done

printf '%s' "$out"
