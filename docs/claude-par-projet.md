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

`superpowers` (skills de processus), `linear` (MCP), `bash-language-server`, `yaml-language-server`, `bash-skills`. Tout le reste est en opt-in par dépôt.

`./install` pose leurs binaires et `shellcheck`, dont le serveur bash a besoin pour ses diagnostics : rien à activer ni à installer par dépôt.

## Installer avant d'activer

Un plugin doit être présent sur la machine pour qu'un dépôt puisse l'activer : il n'y a **pas** de récupération à la demande. Un dépôt qui active un plugin absent échoue sans rien dire d'autre que `plugin-cache-miss` dans le log de debug.

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

| Plugin          | Skills                                                                 |
| --------------- | ---------------------------------------------------------------------- |
| `python-skills` | `django-expert` `fastapi-expert` `python-pro` `sql-pro` `postgres-pro` |
| `unity-skills`  | `csharp-developer` `game-developer`                                    |
| `front-skills`  | `playwright-expert` `typescript-pro` `javascript-pro`                  |
| `devops-skills` | `devops-engineer` `terraform-engineer`                                 |

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

```bash
sudo pacman -S dotnet-sdk
dotnet tool install --global csharp-ls
```

Le plugin Unity Technologies apporte 29 skills (~3 350 tokens) : projet Unity uniquement. Sans `csharp-ls`, `csharp-lsp` s'enregistre mais ne démarre jamais — aucun diagnostic C#. Le SDK .NET n'est pas installé par `./install`, il ne sert qu'ici.

Le pont MCP vers l'Éditeur est un projet tiers, à déclarer dans un `.mcp.json` à la racine du dépôt.

## YAML

Le serveur est actif partout. Associer un schéma par un commentaire en tête de fichier :

```yaml
# yaml-language-server: $schema=https://json.schemastore.org/github-workflow.json
```

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

## DevOps et Terraform

`.claude/settings.json` du dépôt :

```json
{
  "enabledPlugins": {
    "devops-skills@local-skills": true,
    "terraform-ls@claude-code-lsps": true
  }
}
```

```bash
sudo pacman -S terraform-ls
```

`devops-engineer` couvre Dockerfile, CI/CD, manifestes Kubernetes, Terraform/Pulumi, GitOps et incidents. `kubernetes-specialist` ferait doublon.

## Ansible

Aucun skill ni plugin LSP au catalogue. Au choix : activer `yaml-language-server` (validation YAML seule), ou monter un plugin LSP maison dans les dotfiles.

`claude/lsp/ansible-language-server/.lsp.json` :

```json
{
  "ansible": {
    "command": "ansible-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": { ".yml": "ansible", ".yaml": "ansible" }
  }
}
```

Avec un `plugin.json` du même nom dans le plugin, et `claude/lsp/.claude-plugin/marketplace.json` qui déclare `{"name": "local-lsps", "plugins": [{"name": "ansible-language-server", "source": "./ansible-language-server", "version": "1.0.0"}]}`.

```bash
npm install -g @ansible/ansible-language-server
pipx install ansible-lint
```

Puis `.claude/settings.json` du dépôt Ansible : `{"enabledPlugins": {"ansible-language-server@local-lsps": true}}`.

`.yml` ne peut être servi que par un seul LSP : ne pas activer `yaml-language-server` et `ansible-language-server` dans le même dépôt, le premier enregistré gagne.

## Autre technologie

```bash
claude plugin marketplace list
claude plugin details <plugin>@<marketplace>   # inventaire + coût en tokens
```

Catalogue officiel : `clangd-lsp` `csharp-lsp` `gopls-lsp` `jdtls-lsp` `kotlin-lsp` `liquid-lsp` `lua-lsp` `php-lsp` `pyright-lsp` `ruby-lsp` `rust-analyzer-lsp` `swift-lsp` `typescript-lsp`. Le marketplace `claude-code-lsps` ajoute `bash-language-server`, `yaml-language-server`, `terraform-ls`. Ces plugins ne contiennent qu'un LICENSE et un README — la déclaration LSP est intégrée à Claude Code, le binaire reste à fournir (le README dit lequel).

LSP absent du catalogue : suivre la recette Ansible.

Serveur MCP : un `.mcp.json` à la racine du dépôt, avec `command`/`args` ou `type: "http"` et `url`. Les schémas MCP sont déférés derrière `ToolSearch`, donc coût contexte négligeable — le critère est l'usage, pas le coût.

Skill propre au projet : `.claude/skills/<nom>/SKILL.md`, frontmatter `name` + `description`. Quoter la `description` si elle contient un deux-points suivi d'un espace, sinon le YAML casse en silence et tous les champs sont ignorés. Seule la description reste en contexte.

`CLAUDE.md` à la racine : ce qu'une session ne peut pas déduire du code — pièges, conventions non standard, interdits. Pas l'arborescence ni les commandes de build.

## Vérifier

```bash
claude --debug-file /tmp/claude.log -p "ok"
grep -E 'Loaded [0-9]+ LSP server|load skills from plugin' /tmp/claude.log
```

- `Loaded 1 LSP server(s) from plugin: <nom>` — enregistré.
- `Starting LSP server instance: plugin:<nom>` — réellement démarré.
- `extension .<ext> already handled by "<plugin>"` — conflit, un autre a gagné.
- `Skipping orphaned enabledPlugins entry <plugin>` — marketplace non enregistré au niveau utilisateur.
