# Fish Shell Configuration

# Paths
fish_add_path ~/.local/bin

# asdf version manager
if test -f ~/.asdf/asdf.fish
    source ~/.asdf/asdf.fish
end

# direnv hook
if command -q direnv
    direnv hook fish | source
end

# fzf key bindings via fzf.fish plugin (installé par Fisher)
# Ctrl-R : historique avec preview
# Ctrl-T : fichiers avec preview
# Alt-C  : cd avec preview

# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim
