# Fish Shell Configuration

# Désactiver le message d'accueil
set -g fish_greeting

# Paths
fish_add_path ~/.local/bin

# asdf version manager
fish_add_path ~/.asdf/shims

# fzf key bindings via fzf.fish plugin (installé par Fisher)
# Ctrl-R : historique avec preview
# Ctrl-T : fichiers avec preview
# Alt-C  : cd avec preview

# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

fish_add_path ~/.cargo/bin
