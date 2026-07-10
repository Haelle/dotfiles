#!/usr/bin/env bash
# tmux-cheatsheet.sh — aide-mémoire des raccourcis tmux les plus utiles.
# Ouvert via `prefix + C-h` (display-popup) ou lancé directement dans un shell.
# Le préfixe par défaut est Ctrl-b (noté <p> ci-dessous).

BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'
BLUE=$'\e[34m'; CYAN=$'\e[36m'; YELLOW=$'\e[33m'; GREEN=$'\e[32m'; RED=$'\e[31m'

title() { printf '\n%s%s %s%s\n' "$BOLD" "$CYAN" "$1" "$RESET"; }
row()   { printf '  %s%-18s%s %s\n' "$YELLOW" "$1" "$RESET" "$2"; }

printf '%s%s╭─ Aide-mémoire tmux ─ (préfixe = Ctrl-b, noté <p>) ─╮%s\n' "$BOLD" "$BLUE" "$RESET"

title "Sessions"
row "tmux new -s nom"   "créer une session (depuis le shell)"
row "<p> N"             "créer une session (depuis tmux, custom)"
row "<p> s"             "lister / choisir une session"
row "<p> \$"            "renommer la session courante"
row "<p> d"             "détacher (la session continue en fond)"
row "tmux a -t nom"     "rattacher une session"
row "<p> ( )"           "session précédente / suivante"

title "Fenêtres (onglets)"
row "<p> c"             "nouvelle fenêtre"
row "<p> 1 2 3"         "aller à la fenêtre N"
row "<p> n / p"         "fenêtre suivante / précédente"
row "<p> ,"             "renommer la fenêtre"
row "<p> &"             "fermer la fenêtre"

title "Panes (splits)"
row "<p> %"             "split vertical  |"
row "<p> \""            "split horizontal ─"
row "<p> flèches"       "naviguer entre les panes"
row "<p> PgUp / PgDn"   "pane suivant / précédent"
row "<p> z"             "zoom / dézoom le pane"
row "<p> x"             "fermer le pane"

title "Copie (mode vi)"
row "<p> ["             "entrer en mode copie / scroll"
row "/  ?"              "rechercher (bas / haut)"
row "Espace puis Entrée" "sélectionner puis copier"

printf '\n%s%s Dashboard Claude %s\n' "$BOLD" "$GREEN" "$RESET"
row "<p> C-w"          "sauter à la session Claude en attente"
row "<p> C-h"          "cet aide-mémoire"
printf '  %s● waiting%s  %s● done%s  %s● actif%s  %s● inactif%s\n' \
    "$RED" "$RESET" "$GREEN" "$RESET" "$BLUE" "$RESET" "$DIM" "$RESET"

printf '\n%sAppuie sur une touche pour fermer…%s' "$DIM" "$RESET"
read -rsn1
