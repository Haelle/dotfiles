# Fish Aliases

# Rails
alias sr 'spring rspec'
alias rsw 'rails server -b 0.0.0.0 -p 3001'
alias rc 'rails console'
alias bg 'bundle exec guard'
alias test-reset 'RAILS_ENV=test rails db:environment:set db:drop db:create db:migrate'
alias mutant 'RAILS_ENV=test bundle exec mutant run'

# Rubocop
alias rubocop 'bundle exec rubocop --format fuubar'
alias rubofix 'bundle exec rubocop -A'

# Unix utilities
alias tree 'tree -C -L 3'
alias grep 'grep --color=auto'
alias ll 'ls -lhF --color=auto'

# SSL/SSH
alias ssl-cert 'openssl x509 -text -noout -in'
alias ssh-id 'eval (ssh-agent -c) && ssh-add'

# Fail2ban
alias fail2ban-all 'sudo fail2ban-client status | grep "Jail list" | sed "s/.*://;s/,//g" | xargs -n1 sudo fail2ban-client status'

# Editors
alias vim 'nvim'
alias v 'nvim (fzf)'

# Systemd (sc- = system, scu- = user)
alias sc-status 'sudo systemctl status'
alias sc-start 'sudo systemctl start'
alias sc-stop 'sudo systemctl stop'
alias sc-restart 'sudo systemctl restart'
alias sc-enable 'sudo systemctl enable'
alias sc-disable 'sudo systemctl disable'
alias sc-logs 'sudo journalctl -fu'
alias scu-status 'systemctl --user status'
alias scu-start 'systemctl --user start'
alias scu-stop 'systemctl --user stop'
alias scu-restart 'systemctl --user restart'

# Docker / Podman
alias dps 'docker ps --format "table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Image}}"'
alias pps 'podman ps --format "table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Image}}"'

# Updates
set -g __dotfiles_dir (realpath (status filename) | path dirname | path dirname | path dirname)
alias update-dotfiles "git -C $__dotfiles_dir pull origin master"
alias update-nvim 'git -C ~/.config/nvim pull origin master'
alias update-all 'update-dotfiles; and update-nvim'
