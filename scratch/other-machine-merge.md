# Merging this machine's config into the dotfiles repo

This repo was just rebuilt around [chezmoi](https://www.chezmoi.io/) from Nick's other machine. It does **not** yet include anything specific to this one. Goal: fold in whatever's unique here, without duplicating what's already covered.

## 0. Prerequisites

```sh
brew install chezmoi   # if not already installed
git clone https://github.com/ndollar/dotfiles.git
```

## 1. See what the repo already manages

Dotfiles live under `home/` (see `.chezmoiroot`). Current coverage: `.zshrc`, `.zprofile`, `.gitconfig`, `.gitignore_global`, `.tmux.conf`, `~/.config/nvim/lua/custom` (kickstart.nvim itself is cloned fresh by `install.sh`, not vendored here), and a trimmed `~/.claude` (global `CLAUDE.md`, `settings.json`, the `pre-commit` skill).

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

## Progress

Done, from this machine's live config:
- `nvim`: this machine's `ruby_lsp` + gitsigns `current_line_blame` customizations now live in `home/dot_config/nvim/lua/custom/plugins/{ruby,gitsigns}.lua` (see below — *not* a vendored `init.lua`).
- `Brewfile`: added `rbenv`, `ruby-build`, `postgresql@14`, `foreman`, `yarn` for local Rails dev, plus `tree-sitter-cli` (see below).
- `dot_zshrc`: added `rbenv` PATH/init, next to the other language version managers (nvm/gvm/go).

**Nvim approach, revised:** initially vendored the whole live `init.lua` (~1000 lines) to carry 3 small edits. Reverted that — instead: `install.sh` uncomments kickstart's one `require 'custom.plugins'` line, and the actual overrides live in small standalone files under `lua/custom/plugins/` (only those files are tracked, not kickstart's own `init.lua` or its loader). Verified live end-to-end via headless Neovim (both the old lazy.nvim-based kickstart this machine was running, and upstream's current `main`).

**Bigger finding:** `install.sh`'s kickstart clone is unpinned from `main`, and upstream kickstart.nvim rewrote itself to Neovim's native `vim.pack` plugin manager on 2026-09-14 (the day before this work) — a full architecture change from the lazy.nvim/Mason setup this machine still runs. Explicitly decided to keep tracking `main` as-is rather than pin to a known-good commit, so the `ruby.lua`/`gitsigns.lua` overrides above target the *new* `vim.pack` structure (tested against a real fresh clone + portable Neovim 0.12.5, not this machine's installed 0.11.5). Also discovered kickstart's new treesitter setup needs the `tree-sitter` CLI (`tree-sitter-cli` formula, not the `tree-sitter` formula — that one's just the library) to compile parsers; added to `Brewfile`. Since `main` is unpinned, a future kickstart rewrite could break these extension points again — worth a quick check the first time `nvim` is opened on the new machine.

Left out from this machine's live config (job/project-specific, per the gut-check above): Sourcetree diff/mergetool config and old `.gitconfig`/`.tmux.conf` content (repo's versions already supersede these), `heroku/brew` tap, Elixir/Erlang, Python 3.8/3.13 + pyenv + miniconda + uv (repo already has python@3.11), Rust, Solana CLI + cargo path, Mono, imagemagick/libheif/krb5/primesieve (transitive/unrelated libs), `docker`/`docker-desktop` cask (repo already covers `docker-compose`), `zsh`/`claude-code` casks (redundant with macOS default / install.sh's curl installer), `mermaid-ascii`/`spl-stake-pool-cli` (unrelated one-off tools).

Still open: **the old work computer itself hasn't been audited** — this session only had filesystem access to the current machine. Repeat steps 1-5 there (or paste its `chezmoi diff` / relevant dotfiles here) before deleting this file.
