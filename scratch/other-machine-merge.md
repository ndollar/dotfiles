# Merging this machine's config into the dotfiles repo

This repo was just rebuilt around [chezmoi](https://www.chezmoi.io/) from Nick's other machine. It does **not** yet include anything specific to this one. Goal: fold in whatever's unique here, without duplicating what's already covered.

## 0. Prerequisites

```sh
brew install chezmoi   # if not already installed
git clone https://github.com/ndollar/dotfiles.git
```

## 1. See what the repo already manages

Dotfiles live under `home/` (see `.chezmoiroot`). Current coverage: `.zshrc`, `.zprofile`, `.gitconfig`, `.gitignore_global`, `.tmux.conf`, `~/.ssh/config` (host aliases only), `~/.config/nvim` (kickstart.nvim-based), and a trimmed `~/.claude` (global `CLAUDE.md`, `settings.json`, the `pre-commit` skill).

## 2. Diff this machine against the repo

For each file above, compare the live version on this machine against `dotfiles/home/dot_*` (or run `chezmoi init` without `--apply`, then `chezmoi diff` to preview every difference at once).

For each difference, decide:
- **Repo version is fine as-is** — nothing to do.
- **This machine has something better/newer** — port it into the repo's copy (e.g. an alias, a plugin, a keymap).
- **This machine has something one-off** — leave it out of the repo, or template it if it's genuinely machine-specific (chezmoi supports per-machine data/templates if that comes up).

## 3. Watch for what NOT to bring over

The last pass on the other machine found (and stripped) job-specific cruft: hardcoded work email, live API tokens sourced from `.zshrc`, an internal helper function, and a `Brewfile` full of that employer's Kubernetes/cloud/protobuf tooling. Do the same gut-check here before adding anything:
- No tokens, keys, or credentials — ever, even in a private repo.
- No absolute paths baked in (`/Users/nick/...`) — use `$HOME` or `~`.
- No employer-internal tool references, internal hostnames, or coworker names.

## 4. Apply and commit

```sh
chezmoi init --apply ./dotfiles   # or wherever you cloned it
```

Edit source files with `chezmoi edit <target>` (or edit directly under the repo's `home/`), then:

```sh
chezmoi cd        # drops you into the source dir
git add -A
git commit -m "..."
git push
```

## 5. Brewfile

Compare `brew bundle dump --force` output on this machine against the repo's `Brewfile`. Add anything genuinely useful and generic; skip anything tied to a specific job or one-off project.

## 6. Clean up

Once this is done, delete this file (`scratch/other-machine-merge.md`) — it's a one-time migration note, not part of the ongoing setup.
