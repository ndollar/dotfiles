# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Dotfiles live under `home/` (see `.chezmoiroot`); everything else at the repo root is a bootstrap asset, not a managed file.

## New machine setup

```sh
git clone https://github.com/ndollar/dotfiles.git
./dotfiles/install.sh
```

This installs Homebrew and chezmoi if missing, symlinks everything in `home/` into place, and installs packages from `Brewfile`.

## Layout

- `home/` — chezmoi source state (`dot_zshrc` → `~/.zshrc`, `dot_config/nvim` → `~/.config/nvim`, etc.)
- `Brewfile` — `brew bundle dump` output; regenerate with `brew bundle dump --force`
- `install.sh` — bootstrap script for a fresh machine

## Updating

`install.sh` points chezmoi's `sourceDir` straight at wherever you cloned this repo (via `~/.config/chezmoi/chezmoi.toml`), rather than the more common `chezmoi init <repo>` flow — that would `git clone` this repo *again* into a separate `~/.local/share/chezmoi`, a second copy disconnected from the one `git pull` actually updates. So there's only ever one clone of this repo on a machine:

```sh
cd wherever/you/cloned/dotfiles
git pull
chezmoi apply    # re-symlink/apply changes
```

Edit files directly under `home/` in your clone, then `git add`/`commit`/`push` as normal.

## Notes

- `nvim`: `install.sh` clones [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) fresh into `~/.config/nvim` (tracking upstream `main`, currently the `vim.pack`-based rewrite as of 2026-09-14); this repo only tracks individual files under `lua/custom/plugins/`, so kickstart's own `init.lua` and its shipped `lua/custom/plugins/init.lua` loader stay untouched and pullable/upstream. `install.sh` uncomments kickstart's `require 'custom.plugins'` line (shipped commented out) so that loader — which requires every other `.lua` file in `lua/custom/plugins/` — actually runs. Our customizations live in those files: `ruby.lua` enables `ruby_lsp` via `vim.lsp.enable()` and Mason (kickstart's core LSP `servers` table doesn't include it), `gitsigns.lua` turns on `current_line_blame` (kickstart's core gitsigns keymaps are on by default already). Because upstream tracks `main` unpinned, a future kickstart rewrite could change these extension points again — if `nvim` starts erroring after a fresh install, check these files against the current kickstart `init.lua` first. Ruby version management (`rbenv`) is handled in `dot_zshrc`/`Brewfile`. `tree-sitter-cli` is in `Brewfile` because kickstart's current treesitter setup needs it to build parsers.
- `iTerm2`: preferences (profile, colors, keybindings) are tracked in `home/dot_config/iterm2/com.googlecode.iterm2.plist` instead of the default `~/Library/Preferences/` location. `install.sh` points iTerm2 at that folder via `defaults write com.googlecode.iterm2 PrefsCustomFolder/LoadPrefsFromCustomFolder`. To have future changes made in iTerm2's own Preferences UI flow back into this file, check "Save changes into folder when iTerm2 quits" under Preferences → General → Preferences.
- Nothing in this repo should ever contain secrets/tokens — use a password manager or `chezmoi`'s encryption support (age/gpg) if that's ever needed.
