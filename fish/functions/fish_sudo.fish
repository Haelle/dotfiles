function fish_user_key_bindings
    # Esc Esc - Préfixer la commande avec sudo
    bind \e\e __fish_prepend_sudo
end

function __fish_prepend_sudo
    set -l cmd (commandline)
    if test -z "$cmd"
        # Ligne vide : prendre la dernière commande
        commandline -r "sudo $history[1]"
    else if string match -q 'sudo *' "$cmd"
        # Déjà sudo : l'enlever
        commandline -r (string replace -r '^sudo ' '' "$cmd")
    else
        # Ajouter sudo
        commandline -r "sudo $cmd"
    end
    commandline -f end-of-line
end
