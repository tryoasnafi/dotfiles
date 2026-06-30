# dotfiles

Personal, reproducible Neovim setup built on [LazyVim](https://www.lazyvim.org).
Clone, run one script, get an identical editor on **macOS or Debian/Ubuntu**.

## What's inside

| Path | Purpose |
| --- | --- |
| `Brewfile` | macOS toolchain: every CLI tool, WezTerm + the Nerd Font, via `brew bundle` |
| `install.sh` | Detects OS: macOS → `brew bundle`; Debian → `apt` + upstream releases. Then symlinks `nvim/` to `~/.config/nvim` |
| `nvim/` | The Neovim config (LazyVim + language extras + overrides) |

## Install (fresh machine)

```sh
git clone <repo-url> ~/asnafi/dotfiles
~/asnafi/dotfiles/install.sh
```

The script auto-detects the OS:

- **macOS**: installs everything from the `Brewfile` via `brew bundle`.
- **Debian / Ubuntu**: `apt` for `git`, `ripgrep`, `fzf`, `fd` (symlinked from
  `fdfind`); upstream release tarballs for **neovim** (apt's is too old),
  **lazygit** and **glab**; WezTerm from its official apt repo (**amd64 only**);
  and JetBrainsMono Nerd Font into `~/.local/share/fonts`. Needs `sudo` (or runs
  as root). Binaries land in `/usr/local/bin`; make sure it's on your `PATH`.

Then:

1. Set your terminal font to **JetBrainsMono Nerd Font** (the installer adds
   WezTerm, set its font in `~/.wezterm.lua`, or use any terminal you prefer).
2. Launch `nvim`. LazyVim installs all plugins on first run.
3. `:checkhealth` to confirm tools are found, `:Mason` to see installed servers.

## Languages wired in

LSP, syntax, formatting, linting, test-running and debugging for:

- **Go**: gopls, gofumpt, goimports, delve (debug), neotest-golang (tests)
- **TypeScript / JavaScript**: vtsls, eslint, prettier
- **Terraform**: terraform-ls
- **Protobuf**: buf (LSP + format)
- **GraphQL**: graphql-language-service
- JSON, YAML, Docker, Markdown, SQL

LSP servers, formatters and linters install on demand via `:Mason`. Language
**runtimes** (Go, Node) are *not* in the `Brewfile`; install them with your own
version manager (mise / asdf / nvm). The optional GitLab review needs Go present.

## Key bindings (beyond LazyVim defaults)

| Keys | Action |
| --- | --- |
| `<leader>gg` | Lazygit (LazyVim default) |
| `<leader>gd` | Diffview: open diff |
| `<leader>gh` | Diffview: current file history |
| `<leader>gw` | Git worktrees: switch / delete |
| `<leader>gW` | Git worktrees: create |
| `<leader>t*` | Run / watch / debug tests (neotest) |
| `<leader>ci` / `<leader>co` | LSP call hierarchy: incoming (callers) / outgoing (callees) |
| `<leader>gl*` | GitLab MR review (optional, see below) |

LazyVim's own cheatsheet: <https://www.lazyvim.org/keymaps>.

## Optional: GitLab MR review

`nvim/lua/plugins/gitlab.lua` enables in-editor merge-request review via
[gitlab.nvim](https://github.com/harrisoncramer/gitlab.nvim). It builds a small
Go server on install and needs a token:

- export `GITLAB_TOKEN` (and `GITLAB_URL` for self-hosted), or
- drop a `.gitlab.nvim` file at a repo root with `auth_token=...`.

Don't want it? Delete `nvim/lua/plugins/gitlab.lua`.

## Reproducibility

After the first `nvim` launch, LazyVim writes `~/.config/nvim/lazy-lock.json`
(which is the symlinked `nvim/lazy-lock.json`). **Commit it**: it pins exact
plugin commits so every machine resolves to the same versions. Run `:Lazy update`
to bump, then commit the changed lock file.
