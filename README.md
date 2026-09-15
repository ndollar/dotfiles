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

```sh
chezmoi edit ~/.zshrc   # edits home/dot_zshrc in this repo
chezmoi apply           # re-symlink/apply changes
chezmoi cd               # drop into the source dir directly
```

Commit and push changes from the chezmoi source dir (`chezmoi cd`) or directly in this repo if you're not using `chezmoi init` locally.

## Notes

- `nvim` config is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
- Nothing in this repo should ever contain secrets/tokens — use a password manager or `chezmoi`'s encryption support (age/gpg) if that's ever needed.
