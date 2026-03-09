# Dotfiles

Configuration personnelle pour environnement de développement (Ubuntu & Arch/CachyOS).

## Installation

```bash
./install
```

## Mode dry-run

Pour visualiser les changements sans les appliquer :

```bash
./install --dry-run
```

## Backups

Lors de l'installation, les fichiers existants sont sauvegardés dans :

```
~/.dotfiles/backup_YYYYMMDD_HHMMSS/
```

## SSH

Configuration sécurisée avec :

- Algorithmes forts uniquement (Ed25519, ChaCha20-Poly1305)
- Multiplexing activé (connexions plus rapides via `~/.ssh/sockets/`)
- Keep-alive pour maintenir les connexions

## Git

Configuration avec signature SSH des commits.

### Alias utiles

| Alias     | Commande                       |
| --------- | ------------------------------ |
| `git st`  | `status`                       |
| `git co`  | `checkout`                     |
| `git ci`  | `commit --verbose`             |
| `git ca`  | `commit --amend`               |
| `git fix` | `commit --amend --no-edit`     |
| `git lg`  | Log compact avec couleurs      |
| `git lgs` | Log avec statut des signatures |
| `git pf`  | `push --force-with-lease`      |
| `git ds`  | `diff --staged`                |

## Fish Shell

Shell moderne avec autosuggestions et completions natives.

### Post-installation

```bash
fish                 # Entrer dans Fish
tide configure       # Configurer le prompt Tide
chsh -s $(which fish) # Définir Fish comme shell par défaut
```

### Plugins installés

- **Tide** - Prompt équivalent à Powerlevel10k
- **fzf.fish** - Intégration fzf (Ctrl-R historique, Ctrl-T fichiers)
- **direnv** - Variables d'environnement par dossier

### Aliases

| Alias | Commande                                |
| ----- | --------------------------------------- |
| `v`   | `nvim (fzf)` - ouvrir fichier avec fzf  |
| `g`              | `git status` (ou `git <cmd>` avec args)      |
| `jwt`            | Décoder un token JWT                          |
| `update-dotfiles` | Pull origin master des dotfiles (depuis n'importe où) |
| `update-nvim`    | Pull origin master de la config NeoVim        |
| `update-all`     | Met à jour dotfiles + NeoVim                  |

### Raccourcis clavier

| Raccourci | Description                    |
| --------- | ------------------------------ |
| `Alt-Up`  | Remonter au dossier parent     |
| `Alt-S`   | Préfixer la commande avec sudo |
| `Ctrl-R`  | Recherche dans l'historique    |
| `Ctrl-T`  | Recherche de fichiers          |
| `Alt-C`   | cd dans un dossier             |

## Cheatsheet tmux

### Sessions

| Commande          | Description                |
| ----------------- | -------------------------- |
| `tmux new -s nom` | Nouvelle session `nom`     |
| `tmux a -t nom`   | Rattacher la session `nom` |
| `tmux ls`         | Lister les sessions        |
| `Ctrl-B d`        | Détacher de la session     |

### Fenêtres (onglets)

| Raccourci    | Description                                   |
| ------------ | --------------------------------------------- |
| `Ctrl-B c`   | Nouvelle fenêtre                              |
| `Ctrl-B ,`   | Renommer la fenêtre                           |
| `Ctrl-B n`   | Fenêtre suivante                              |
| `Ctrl-B p`   | Fenêtre précédente                            |
| `Ctrl-B 1-9` | Aller à la fenêtre N (clavier FR : Shift+1-9) |
| `Ctrl-B w`   | Explorer les fenêtres (vue arborescente)      |

### Panes (splits)

| Raccourci     | Description              |
| ------------- | ------------------------ |
| `Ctrl-B %`    | Split vertical           |
| `Ctrl-B "`    | Split horizontal         |
| `Ctrl-B ←↑↓→` | Naviguer entre les panes |

**Note navigation** : Après `Ctrl-B ←↑↓→`, il y a un court délai avant de récupérer le focus. Si vous appuyez sur ↑ trop vite pour l'historique des commandes, ça change de pane.

### Resize

| Méthode            | Description                                     |
| ------------------ | ----------------------------------------------- |
| Souris             | Glisser les bordures entre les panes            |
| `Ctrl-B Ctrl-←↑↓→` | Redimensionner avec le clavier (maintenir Ctrl) |

### Scroll / Copie

| Méthode             | Description                                              |
| ------------------- | -------------------------------------------------------- |
| Molette souris      | Scroller dans l'historique                               |
| `Ctrl-B PgUp-PgDn` | Scroller dans l'historique                               |
| Clic gauche + drag  | Sélectionner et copier dans le clipboard au relâchement  |
| `Ctrl-B ]`          | Coller depuis le buffer tmux                             |
| `Ctrl-Shift-V`      | Coller depuis le clipboard système (raccourci terminal)  |

## Offline install

Pour `git`, `tmux`, `ssh` pas de dépendances offline, on peut donc cloner et faire :

```bash
./install git tmux ssh
```

### Déploiement offline de Fish

Par contre Fish a besoin d'internet mais une installation locale peut être exportée car ça ne nécessite aucune dépendances qui ne soit dans un dépôt Debian/Ubuntu. Sur la machine source :

```bash
cp -rL ~/.config/fish /tmp/fish && tar czf fish.tar.gz -C /tmp fish && rm -rf /tmp/fish
```

Sur la machine cible :

```bash
tar xzf fish.tar.gz -C ~/.config/
```

P.S: les dépendances sont `fish`, `fzf`, `git`, `jq`, `tree` et `direnv`. Elles sont installées si `./install git (et/ou) tmux (et/ou) ssh` ont été installés.

### NeoVim offline

Le script `./install-neovim-offline` installe neovim, fzf et ripgrep via apt avec une config simple. Il reprend une partie des options, keymaps et autocommands de kickstart.nvim sans nécessiter internet.
Il n'est pas aussi simple d'avoir un mode offline comme Fish car il y a trop de dépendances système et Mason & cie auto installe pleins de choses en background.

```bash
./install-neovim-offline
./install-neovim-offline --dry-run
```

La config est symlinquée depuis `nvim-offline/` vers `~/.config/nvim`.

#### Options

- Leader : `Space`
- Indentation : 2 espaces (expandtab)
- Numéros de ligne, cursorline, scrolloff 10
- Recherche smartcase, highlight search (Esc pour clear)
- Undo persistant, clipboard système
- Caractères invisibles affichés (tab, trailing spaces, nbsp)

#### Keymaps

- quick save

| Raccourci          | Description                                           |
| ------------------ | ----------------------------------------------------- |
| \<Space\>sn        | [S]earch [N]eovim config neovim (vsplit)              |
| \<Space\>sk        | [S]earch [K]eymaps (fzf)                              |
| u                  | [U]ndo                                                |
| \<C-r\>            | [R]edo                                                |
| \<C-s\>            | quick [S]ave file                                     |
| \<Space\>sg        | [S]earch with [G]rep (récursif) w/ ripgrep + quickfix |
| \<Space\>sf        | [S]earch [F]ile by name (rg + fzf)                    |
| \<C-Space\>        | Autocomplétion (mots du buffer)                       |
| \<Tab\>/<S-Tab\>   | Naviguer dans le menu de complétion                   |
| \<Left\>/<Right\>  | Naviguer dans le menu de complétion                   |
| \<C-y\>            | [Y]es, accept selection in completion mode            |
| \<Esc\>            | Clear search highlight                                |
| \<C-w\>Arrows      | Navigation entre splits                               |
| \<C-w\><S-Arrows\> | Déplacer les splits                                   |
| \<Esc\><Esc\>      | Quitter le mode terminal                              |
| gr                 | [G]o to [R]eferences (rg + fzf)                       |
| gd                 | [G]o to [D]efinition (fichier ouvert)                 |
| gf                 | [G]o to [F]ile                                        |
| \<C-o\>            | previous opened file                                  |
| Tab                | next opened file                                      |
| \<Space\>st        | [S]earch [T]ODO/FIXME/HACK/NOTE (fzf)                 |

#### Autocommands

- Highlight on yank
- Restauration de la position du curseur

#### Filetype detection

- `docker-compose.yml/yaml` (et variantes)
- `.gitlab-ci.yml`
- `values*.yml/yaml` (Helm)
- `*.mdx` → markdown
