# Configuration Claude Code par projet

La liste des skills est budgétée à ~1 % du contexte (~2 000 tokens). Au-delà elle est tronquée : les skills en trop perdent leur description et deviennent inatteignables. D'où l'inversion du défaut — le niveau utilisateur garde le strict universel, chaque dépôt active ce dont il a besoin.

## Règles

| Élément | `~/.claude/settings.json` | `.claude/settings.json` (dépôt) |
| --- | --- | --- |
| `extraKnownMarketplaces` | **obligatoire** | **ignoré** |
| `enabledPlugins` | défauts globaux | spécialisation |
| `.mcp.json` | — | racine du dépôt |
| `.claude/skills/` | — | dans le dépôt |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | racine du dépôt |

Un dépôt peut réactiver un plugin coupé au niveau utilisateur, mais pas déclarer son propre marketplace (`Skipping orphaned enabledPlugins entry`).

`.claude/settings.json` est fait pour être commité ; seul `.claude/settings.local.json` est gitignoré. Attention : il est appliqué par le Claude de quiconque clone le dépôt — même modèle de confiance qu'un `Makefile` ou un workflow CI.

## Actif au niveau utilisateur

`superpowers` (skills de processus), `linear` (MCP), `bash-language-server`, `yaml-language-server`, `bash-skills`. Tout le reste est en opt-in par dépôt, language servers compris : ils ne coûtent rien en contexte mais démarrent un processus.

## Marketplace de skills local

`claude/skills/` regroupe par techno une sélection de [jeffallan/claude-skills](https://github.com/jeffallan/claude-skills) (MIT) — le plugin complet dépasse 60 skills et ~8 000 tokens.

| Plugin | Skills |
| --- | --- |
| `python-skills` | `django-expert` `fastapi-expert` `python-pro` `sql-pro` `postgres-pro` |
| `unity-skills` | `csharp-developer` `game-developer` |
| `front-skills` | `playwright-expert` `typescript-pro` `javascript-pro` |
| `devops-skills` | `devops-engineer` `terraform-engineer` |
| `bash-skills` | `cli-developer` — **actif au niveau utilisateur**, rien à activer par dépôt |

Déclaré dans `claude/settings.json`, Claude le réenregistre seul — le premier lancement amorce, le suivant voit les skills :

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

## Bash

```json
{ "enabledPlugins": { "bash-language-server@claude-code-lsps": true } }
```

```bash
npm install -g bash-language-server
sudo pacman -S shellcheck
```

Sans `shellcheck`, pas de diagnostics — seulement syntaxe et navigation.

`bash-skills` et `bash-language-server` étant actifs au niveau utilisateur, ce bloc ne sert que sur une machine neuve ou pour être explicite : réactiver un plugin déjà actif est sans effet.

## Python

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

Le pont MCP vers l'Éditeur est un projet tiers, à déclarer dans un `.mcp.json` à la racine.

## YAML

```json
{ "enabledPlugins": { "yaml-language-server@claude-code-lsps": true } }
```

```bash
npm install -g yaml-language-server
```

Associer un schéma par un commentaire en tête de fichier :

```yaml
# yaml-language-server: $schema=https://json.schemastore.org/github-workflow.json
```

## DevOps et Terraform

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
