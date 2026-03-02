# Dotfiles

Configuration personnelle pour environnement de développement (Ubuntu & Arch/CachyOS).

## Installation

```bash
./bin/install-offline
```

## Mode dry-run

Pour visualiser les changements sans les appliquer :

```bash
./bin/install-offline --dry-run
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

 | Alias     | Commande                        |
 | --------  | ------------------------------- |
 | `git st`  | `status`                        |
 | `git co`  | `checkout`                      |
 | `git ci`  | `commit --verbose`              |
 | `git ca`  | `commit --amend`                |
 | `git fix` | `commit --amend --no-edit`      |
 | `git lg`  | Log compact avec couleurs       |
 | `git lgs` | Log avec statut des signatures  |
 | `git pf`  | `push --force-with-lease`       |
 | `git ds`  | `diff --staged`                 |

## Cheatsheet tmux

### Sessions

 | Commande          | Description                |
 | ----------        | -------------              |
 | `tmux new -s nom` | Nouvelle session `nom`     |
 | `tmux a -t nom`   | Rattacher la session `nom` |
 | `tmux ls`         | Lister les sessions        |
 | `Ctrl-B d`        | Détacher de la session     |

### Fenêtres (onglets)

 | Raccourci    | Description                                   |
 | -----------  | -------------                                 |
 | `Ctrl-B c`   | Nouvelle fenêtre                              |
 | `Ctrl-B ,`   | Renommer la fenêtre                           |
 | `Ctrl-B n`   | Fenêtre suivante                              |
 | `Ctrl-B p`   | Fenêtre précédente                            |
 | `Ctrl-B 1-9` | Aller à la fenêtre N (clavier FR : Shift+1-9) |
 | `Ctrl-B w`   | Explorer les fenêtres (vue arborescente)      |

### Panes (splits)

 | Raccourci     | Description              |
 | -----------   | -------------            |
 | `Ctrl-B %`    | Split vertical           |
 | `Ctrl-B "`    | Split horizontal         |
 | `Ctrl-B ←↑↓→` | Naviguer entre les panes |

**Note navigation** : Après `Ctrl-B ←↑↓→`, il y a un court délai avant de récupérer le focus. Si vous appuyez sur ↑ trop vite pour l'historique des commandes, ça change de pane.

### Resize

 | Méthode            | Description                                     |
 | ---------          | -------------                                   |
 | Souris             | Glisser les bordures entre les panes            |
 | `Ctrl-B Ctrl-←↑↓→` | Redimensionner avec le clavier (maintenir Ctrl) |

### Scroll / Copie

 | Méthode            | Description                |
 | ---------          | -------------              |
 | Molette souris     | Scroller dans l'historique |
 | `Ctrl-B PgUp-PgDn` | Scroller dans l'historique |
 | Surligner          | Copie                      |
