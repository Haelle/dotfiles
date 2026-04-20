# Charge tous les fichiers .fish de ~/.config/fish/local.d/ (non versionnés)
# Pour secrets, tokens, configs spécifiques à une machine
set -l local_dir $HOME/.config/fish/local.d

if test -d $local_dir
    for f in $local_dir/*.fish
        source $f
    end
end
