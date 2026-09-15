# Configuration Claude Code par projet

La liste des skills est budgétée à ~1 % du contexte (~2 000 tokens). Au-delà elle est tronquée : les skills en trop perdent leur description et deviennent inatteignables. Niveau utilisateur on charge le strict universel, chaque dépôt active ce dont il a besoin.

## Règles

| Élément                  | `~/.claude/settings.json` | `.claude/settings.json` (dépôt) |
| ------------------------ | ------------------------- | ------------------------------- |
| `extraKnownMarketplaces` | **obligatoire**           | **ignoré**                      |
| `enabledPlugins`         | défauts globaux           | spécialisation                  |
| `.mcp.json`              | —                         | racine du dépôt                 |
| `.claude/skills/`        | —                         | dans le dépôt                   |
| `CLAUDE.md`              | `~/.claude/CLAUDE.md`     | racine du dépôt                 |

Un dépôt peut réactiver un plugin coupé au niveau utilisateur, mais pas déclarer son propre marketplace (`Skipping orphaned enabledPlugins entry`).

`.claude/settings.json` est fait pour être commité ; seul `.claude/settings.local.json` est gitignoré. Attention : il est appliqué par le Claude de quiconque clone le dépôt — même modèle de confiance qu'un `Makefile` ou un workflow CI.

## Actif au niveau utilisateur

`superpowers` (skills de processus), `linear` (MCP), `bash-language-server`, `yaml-language-server`, `bash-skills`, `core-skills` (revue, debug, sécurité, tests). Tout le reste est en opt-in par dépôt.

`./install` pose leurs binaires et `shellcheck`, dont le serveur bash a besoin pour ses diagnostics : rien à activer ni à installer par dépôt.

## Installer avant d'activer

Un plugin d'un marketplace **distant** doit être présent sur la machine pour qu'un dépôt puisse l'activer : il n'y a pas de récupération à la demande, et un dépôt qui en active un absent échoue sans rien dire d'autre que `plugin-cache-miss` dans le log de debug.

Les plugins d'un marketplace `directory` — `local-skills` ici — échappent à ça : Claude les lit directement dans le dossier source via le symlink, sans cache ni installation.

`./install` s'en charge : `CLAUDE_PROJECT_PLUGINS` dans `lib/claude.sh` liste les plugins à poser. Ils sont installés après le merge des settings, qui déclare les marketplaces — sans eux `claude plugin install` échoue. La fonction reprend ensuite `enabledPlugins` du dépôt, ce qui efface les clés `true` que l'installation vient d'écrire. Ajouter une techno se fait en une ligne dans ce tableau.

Conséquence à connaître : `enabledPlugins` est **autoritaire depuis le dépôt**. Un plugin activé à la main au niveau utilisateur sera remis dans son scope au prochain `./install`. Pour le garder actif partout, l'ajouter à `claude/settings.json` des dotfiles.

À la main, c'est deux commandes, la seconde parce que `claude plugin install` active le plugin partout :

```bash
claude plugin install unity@claude-plugins-official
S=~/.claude/settings.json
jq 'del(.enabledPlugins["unity@claude-plugins-official"])' "$S" > "$S.tmp" && mv "$S.tmp" "$S"
```

Sans clé, le plugin reste installé mais inactif ; un dépôt peut l'activer. `claude plugin disable` fait de même mais laisse une entrée `false` sans effet utile.

L'activation, elle, est automatique : le `.claude/settings.json` versionné du dépôt suffit, il n'y a aucune commande à lancer en y entrant.

## Marketplace de skills local

`claude/skills/` regroupe par techno une sélection de [jeffallan/claude-skills](https://github.com/jeffallan/claude-skills) (MIT) — le plugin complet dépasse 60 skills et ~8 000 tokens.

| Plugin          | Skills                                                                                |
| --------------- | ------------------------------------------------------------------------------------- |
| `core-skills`   | `code-reviewer` `debugging-wizard` `security-reviewer` `test-master`                  |
| `bash-skills`   | `cli-developer`                                                                       |
| `python-skills` | `django-expert` `fastapi-expert` `python-pro` `sql-pro` `postgres-pro` `api-designer` |
| `unity-skills`  | `csharp-developer` `game-developer`                                                   |
| `front-skills`  | `playwright-expert` `typescript-pro` `javascript-pro`                                 |
| `devops-skills` | `devops-engineer` `terraform-engineer`                                                |

`core-skills` et `bash-skills` sont actifs au niveau utilisateur, les autres s'activent par dépôt.

Déclaré dans `claude/settings.json` des dotfiles (pas dans un dépôt : voir le tableau des règles), Claude le réenregistre seul — le premier lancement amorce, le suivant voit les skills :

`claude/settings.json` des dotfiles :

```json
{
  "extraKnownMarketplaces": {
    "local-skills": {
      "source": { "source": "directory", "path": "~/.claude/local-skills" }
    }
  }
}
```

Le chemin est fixe : `./install` pose `~/.claude/local-skills` en lien vers `claude/skills` du clone, quel que soit son emplacement. En écriture manuelle, le tilde est développé mais `$HOME` et les chemins relatifs **non**.

Ajouter un skill : copier son dossier dans `claude/skills/<lot>/skills/`, relancer une session.

## Python

`.claude/settings.json` du dépôt :

```json
{
  "enabledPlugins": {
    "pyright-lsp@claude-plugins-official": true,
    "python-skills@local-skills": true
  }
}
```

```bash
npm install -g pyright
```

En présence d'un virtualenv, préciser `venvPath` et `venv` dans `pyrightconfig.json` ou `[tool.pyright]`, sinon faux positifs.

## Svelte

`.claude/settings.json` du dépôt :

```json
{
  "enabledPlugins": {
    "svelte@svelte": true,
    "typescript-lsp@claude-plugins-official": true,
    "front-skills@local-skills": true
  }
}
```

```bash
npm install -g svelte-language-server typescript-language-server typescript
```

Le plugin officiel fournit LSP, serveur MCP de doc, deux skills et l'agent `svelte-file-editor` — rien à déclarer en plus. SvelteKit y est traité sans skill dédié.

Deux conditions, sinon diagnostics incomplets : `svelte` dans les `node_modules` du projet, et `typescript-svelte-plugin` dans les `plugins` du `tsconfig.json` pour le TS dans les `.svelte`.

Le LSP appelle `svelteserver` via le PATH : un binaire posé par Mason (Neovim) n'y est pas.

## Unity

`.claude/settings.json` du dépôt :

```json
{
  "enabledPlugins": {
    "unity@claude-plugins-official": true,
    "csharp-lsp@claude-plugins-official": true,
    "unity-skills@local-skills": true
  }
}
```

Pour le plugin PixelLab il faut aller chercher la commande dans son [espace personnel PixelLabs](https://www.pixellab.ai/mcp)

```bash
sudo pacman -S dotnet-sdk          # CachyOS / Arch — dépôt extra
sudo apt install dotnet-sdk-10.0   # Debian / Ubuntu récents
dotnet tool install --global csharp-ls
```

Pour le MCP LDtk `.mcp.json` du dépôt :

```json
{
  "mcpServers": {
    "ldtk": {
      "type": "stdio",
      "command": "ldtk-mcp",
      "args": [],
      "env": {}
    }
  }
}
```

```bash
# Pour le MCP LDtk
sudo pacman -S --asexplicit rust
cargo install --git https://github.com/gazure/ldtk-mcp
claude mcp add ldtk ldtk-mcp -s project
```

Sur une Ubuntu plus ancienne, `dotnet-sdk-*` n'est pas dans les archives et demande le dépôt Microsoft.

Le plugin Unity Technologies apporte 29 skills (~3 350 tokens) : projet Unity uniquement. Sans `csharp-ls`, `csharp-lsp` s'enregistre mais ne démarre jamais — aucun diagnostic C#. Le SDK .NET n'est pas installé par `./install`, il ne sert qu'ici.

Le pont MCP vers l'Éditeur est un projet tiers, à déclarer dans un `.mcp.json` à la racine du dépôt.

## Lua et Neovim

`.claude/settings.json` du dépôt :

```json
{ "enabledPlugins": { "lua-lsp@claude-plugins-official": true } }
```

Le binaire n'est pas sur npm, il s'installe depuis les releases GitHub :

```bash
LUALS=$(curl -sL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r .tag_name)
mkdir -p ~/.local/lib/lua-language-server
curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/$LUALS/lua-language-server-$LUALS-linux-x64.tar.gz" \
  | tar xz -C ~/.local/lib/lua-language-server
ln -sf ~/.local/lib/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
```

Pour une config Neovim, un `.luarc.json` à la racine évite les faux positifs sur les globales de l'éditeur :

```json
{
  "runtime": { "version": "LuaJIT" },
  "diagnostics": { "globals": ["vim"] },
  "workspace": { "library": ["$VIMRUNTIME/lua"] }
}
```

## DevOps et Ansible/Terraform

`.claude/settings.json` du dépôt :

```json
{
  "enabledPlugins": {
    "devops-skills@local-skills": true,
    "terraform-ls@claude-code-lsps": true
  }
}
```

`terraform-ls` n'est pas dans les dépôts officiels d'Arch, il vient de l'AUR :

```bash
sudo pacman -S terraform-ls
sudo apt-get install terraform-ls
```

`devops-engineer` couvre Dockerfile, CI/CD, manifestes Kubernetes, Terraform/Pulumi, GitOps et incidents. `kubernetes-specialist` ferait doublon.
