Check the availability and functionality of all LSP servers configured in ~/.claude/settings.json.

For each LSP plugin listed in `enabledPlugins` that ends with `@claude-plugins-official` or `@claude-code-lsps`:
1. Identify the binary name expected by the plugin
2. Check if the binary is available in $PATH using `which`
3. Try running it with `--version` or `--help` to confirm it works

Display a summary table with columns: Plugin name, Binary, Status (✅ available / ❌ missing), Version.
If a binary is missing, suggest the install command.
