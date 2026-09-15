Check the availability and functionality of the LSP servers active in the current context.

## Resolve the effective plugin set

Plugins cascade `user < project < local`. Merge the three files, keeping only entries set to `true`:

```bash
for f in ~/.claude/settings.json .claude/settings.json .claude/settings.local.json; do
    [ -f "$f" ] && echo "$f"
done | xargs jq -s 'map(.enabledPlugins // {}) | add | with_entries(select(.value == true)) | keys[]'
```

Missing files are normal — most repositories have none. Filter them out first: passing a path that does not exist makes `jq` print an error and still emit a partial result, which reads as a valid answer. Note which scope each plugin comes from, since that is what the report has to explain.

## Find which ones declare a language server

Do not filter on the marketplace suffix: a plugin declares an LSP either through a `.lsp.json` at its root, or through an `lspServers` key in `.claude-plugin/plugin.json`. For each enabled plugin, look under `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` and read the `command` it declares.

```bash
find ~/.claude/plugins/cache -name '.lsp.json' -o -name 'plugin.json' -path '*/.claude-plugin/*'
```

The official `*-lsp` plugins contain only a LICENSE and a README: their declaration is built into Claude Code and the binary name is in the README.

## Check each binary

Resolve it with `command -v`, then run it with `--version` (or `--help`). Two failure modes matter and look alike from the outside:

- The binary is missing from `$PATH` — often a language server installed by Mason for Neovim, which puts it in `~/.local/share/nvim/mason/bin`, not in `$PATH`.
- The binary resolves but does not run. An asdf shim whose package was installed under a different Node version answers `No version is set for command <name>`, so `command -v` succeeds while the server never starts.

## Report

A table with: Plugin, Scope (user / project), Binary, Status (✅ / ❌), Version.

Then flag separately:

- Plugins enabled but not installed on this machine. A repository cannot pull a plugin on demand; the session logs `plugin-cache-miss` and the server silently never starts. Fix: `claude plugin install <plugin>@<marketplace>`.
- Extension conflicts: one extension is served by a single LSP, the first registered wins and the session logs `extension .<ext> already handled by "<plugin>"`.

For every missing binary, give the install command for both CachyOS/Arch and Debian/Ubuntu.

To confirm what actually started rather than what is merely declared:

```bash
claude --debug-file /tmp/lsp.log -p "ok"
grep -E 'Loaded [0-9]+ LSP server|Starting LSP server instance|already handled by' /tmp/lsp.log
```
