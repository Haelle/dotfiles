#!/usr/bin/env bash
# cc-tabs.sh — rend les onglets de la session courante en PLEINE LARGEUR sous forme
# de pilules ARRONDIES (demi-cercles powerline), réparties équitablement
# (chaque onglet = largeur/N), colorées par @cc_state. Couleurs : voir cc-colors.sh.
#   actif -> bleu · waiting -> rouge clignotant · done -> vert · idle -> bleu-gris
# Utilisé par status-format[2]. Reçoit la largeur du client en $1 (fallback query).
# Nerd Font requise pour les bouts arrondis (MesloLGS NF etc.).

source "${0%/*}/cc-colors.sh"

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
pulse=$(( $(date +%s) % 2 ))                    # parité 1s : fait clignoter le FOND

out=""
for (( k=0; k<n; k++ )); do
    seg=$base
    [ "$k" -lt "$rem" ] && seg=$(( base + 1 ))
    inner=$(( seg - 2 )); (( inner < 1 )) && inner=1   # 2 colonnes réservées aux bouts arrondis

    e=$(cc_state_emoji "${states[k]}")                 # emoji = 2 colonnes mais 1 char bash
    label="${e}${idxs[k]}:${names[k]}"
    extra=0; [ -n "$e" ] && extra=1                    # compense la colonne d'affichage manquante
    disp=$(( ${#label} + extra ))                      # largeur d'affichage réelle
    if (( disp > inner )); then                        # tronque pour tenir dans le corps
        cut=$(( inner - extra )); (( cut < 0 )) && cut=0   # garde-fou : jamais de longueur négative
        label="${label:0:cut}"; disp=$(( ${#label} + extra ))
    fi

    pad=$(( inner - disp )); (( pad < 0 )) && pad=0
    left=$(( pad / 2 )); right=$(( pad - left ))
    pad_l=$(printf '%*s' "$left" ''); pad_r=$(printf '%*s' "$right" '')

    [ "${actives[k]}" = "1" ] && focus=1 || focus=0
    cc_pill_colors "$focus" "${states[k]}" "$pulse"

    # pilule arrondie : demi-cercle gauche + corps (padding + label) + demi-cercle droit
    pill="#[fg=${PBG},bg=${BAR}]${LC}#[bg=${PBG},fg=${PFG}${PBOLD}]${pad_l}${label}${pad_r}#[fg=${PBG},bg=${BAR}]${RC}"
    # range=window|N : rend le segment cliquable (MouseDown1Status -> select-window)
    out="${out}#[range=window|${idxs[k]}]${pill}#[norange]#[default]"
    [ "$k" -lt $(( n - 1 )) ] && out="${out}${gutter}"   # gouttière sauf après le dernier
done

printf '%s' "$out"
