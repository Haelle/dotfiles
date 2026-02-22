# Dotfiles

Cross-platform dotfiles for **Ubuntu**, **Arch Linux**, and **CachyOS**.

Two installation modes:
- **`bin/install-offline`** — Degraded mode, only needs package repository access
- **`bin/install-online`** — Full mode with internet (Oh My ZSH, NeoVim + LSP, Starship curl install)

## Quick Start

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# Offline mode (package repos only)
./bin/install-offline

# Online mode (full internet)
./bin/install-online
```

The installer will:
1. Detect your distro (Ubuntu/Arch/CachyOS)
2. Install packages via apt or pacman
3. Backup existing dotfiles to `~/.dotfiles_backup/YYYYMMDD_HHMMSS/`
4. Deploy symlinks
5. Ask for git identity (stored in `~/.gitconfig.local`)
6. Propose changing default shell to zsh

---

## Modules

### ZSH

**Online mode** — Oh My ZSH with 30+ plugins:
- docker, docker-compose, kubectl, aws, terraform
- fzf, tmux, direnv, dotenv, vscode
- nvm, rbenv, ruby, rails, python, pip, asdf
- sudo (double ESC), command-not-found, jsontools, encode64
- zsh-autosuggestions, zsh-syntax-highlighting

**Offline mode** — Manual compinit setup:
- Tab-completion with menu selection and case-insensitive matching (`git <tab>` shows subcommands)
- History search with arrow keys (type prefix, then Up/Down)
- Autosuggestions from history (system package)
- Syntax highlighting in real-time (system package)

**Both modes:**
- Starship cross-shell prompt (git branch, detected language, command duration, k8s context)
- Shared aliases and functions sourced from `~/.aliases` and `~/.functions`
- FZF integration with fd as default finder

### Git

**Aliases:**
- `st` (status), `co` (checkout), `sw` (switch), `br` (branch)
- `lg` (log graph), `lga` (log all branches)
- `p` (push), `pf` (push --force-with-lease)
- `cancel` (soft reset HEAD~1), `wip` / `unwip`
- `cleanup` (delete merged branches)

**Configuration:**
- Delta as pager — colorized diffs, side-by-side, line numbers
- `pull.rebase = true` + `rebase.autostash = true` (rebase workflow)
- `push.autoSetupRemote = true` (no more `--set-upstream`)
- `rerere.enabled = true` (remembers conflict resolutions)
- `merge.conflictstyle = diff3` (shows base in conflicts)
- Global gitignore (IDE, OS, .env, tags, node_modules, __pycache__)
- Identity in `~/.gitconfig.local` (not versioned) via `[include]`

### Vim (offline)

- Universal-ctags for go-to-definition (`Ctrl-]`) — ~130 languages supported
- `gf` for go-to-file under cursor
- netrw as file explorer (`<leader>e`)
- Persistent undo across sessions
- Window navigation: `Ctrl-h/j/k/l`
- Buffer navigation: `Tab` / `Shift-Tab`
- Leader key: `Space`
- File-type specific indentation (2 spaces for yaml/json/js/ruby/lua)

### NeoVim (online)

**LSP (native):**
- Go-to-definition `gd`, declaration `gD`, implementation `gi`
- Hover documentation `K`
- References `gr`
- Rename `<leader>rn`, code action `<leader>ca`

**Auto-installed LSP servers (via Mason):**
`lua_ls`, `pyright`, `ts_ls`, `bashls`, `gopls`, `rust_analyzer`, `ansiblels`, `dockerls`, `yamlls`, `jsonls`

**Plugins (lazy.nvim):**
- **nvim-cmp** — Autocompletion (LSP, snippets, buffer, path)
- **Telescope** — Fuzzy find files (`<leader>ff`), live grep (`<leader>fg`), buffers (`<leader>fb`)
- **Treesitter** — Advanced syntax highlighting, incremental selection
- **gitsigns** — Git hunks in sign column, stage/reset/preview
- **which-key** — Keybinding hints on leader press
- **lualine** — Statusline with git branch, diagnostics, filetype
- **tokyonight** — Color scheme
- **indent-blankline** — Indent guides
- **Comment.nvim** — `gcc` to comment line, `gc` in visual
- **nvim-autopairs** — Auto-close brackets and quotes

### Tmux

- Prefix: `Ctrl-a` (instead of `Ctrl-b`)
- Split: `|` (horizontal) and `-` (vertical), opens in current directory
- Pane navigation: vim-style `h/j/k/l`
- Pane resize: `H/J/K/L` (repeatable)
- Copy mode: vi keys — `v` to select, `y` to copy to clipboard
- Mouse enabled
- 50,000 lines history
- Reload config: `prefix + r`
- Tokyo Night inspired status bar

### SSH

- **Ciphers:** chacha20-poly1305, aes256-gcm, aes128-gcm only
- **Key exchange:** sntrup761 (post-quantum), curve25519
- **MACs:** hmac-sha2-512-etm, hmac-sha2-256-etm
- **Host keys:** ssh-ed25519, rsa-sha2-512/256
- `AddKeysToAgent yes`, `IdentitiesOnly yes`
- Keepalive every 60s (3 max retries)
- Compression enabled

### Aliases & Functions

**Navigation:** `..`, `...`, `....`

**Listing:** `ll` (detailed), `la` (hidden), `tree` (3 levels)

**Docker:** `dps` (formatted ps), `dlog` (follow logs), `dexec` (exec -it), `dc`/`dcu`/`dcd` (compose)

**Git shortcuts:** `gs`, `gd`, `ga`, `gc`, `gp`, `gl`, `glog`

**Functions:**
- `g` — git status (no args) or git passthrough
- `mkcd` — mkdir + cd
- `extract` — extract any archive (tar, zip, 7z, rar, xz, zst...)
- `jwt` — decode JWT token (header + payload)
- `fshow` — interactive git log browser with fzf
- `fkill` — kill process with fzf
- `tre` — tree with less, ignoring .git/node_modules
- `up N` — go up N directories
- `serve` — quick Python HTTP server

**Auto-aliases:**
- `vim` → `nvim` if neovim is available
- `fd` → `fdfind` on Ubuntu
- `bat` → `batcat` on Ubuntu
- `vfzf` — open file via fzf in vim

---

## Structure

```
dotfiles/
├── bin/
│   ├── install-online          # Full installer (internet required)
│   ├── install-offline         # Minimal installer (repos only)
│   └── lib/
│       ├── common.sh           # Logging, detect_distro, backup, symlink
│       ├── packages.sh         # Package mapping apt/pacman + install
│       └── symlink.sh          # Symlink orchestration
├── shell/
│   ├── aliases.sh              # Shared aliases (bash + zsh)
│   ├── functions.sh            # Shared functions
│   ├── bashrc                  # Bash config
│   ├── zshrc-online            # ZSH + Oh My ZSH
│   ├── zshrc-offline           # ZSH manual (compinit)
│   └── starship.toml           # Cross-shell prompt
├── git/
│   ├── gitconfig               # Git config (includes ~/.gitconfig.local)
│   └── gitignore_global        # Global gitignore
├── tmux/
│   └── tmux.conf               # Tmux config
├── ssh/
│   └── config                  # SSH hardened config
├── vim/
│   └── vimrc                   # Vim config (offline, ctags)
├── nvim/                       # NeoVim (online only)
│   ├── init.lua
│   └── lua/
│       ├── options.lua
│       ├── keymaps.lua
│       └── plugins/
│           ├── init.lua        # lazy.nvim bootstrap
│           ├── lsp.lua         # mason + lspconfig
│           ├── cmp.lua         # nvim-cmp
│           ├── telescope.lua   # Fuzzy finder
│           ├── treesitter.lua  # Syntax highlighting
│           └── ui.lua          # Theme, lualine, gitsigns, which-key
└── ctags/
    └── ctags.d/
        └── default.ctags       # Universal-ctags config
```

## Customization

- **Git identity:** Edit `~/.gitconfig.local`
- **Local shell overrides:** Create `~/.bashrc.local` or `~/.zshrc.local`
- **Re-run installer:** Safe to run multiple times (idempotent). Existing files are backed up.
