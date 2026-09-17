# Install notes

Findings from setting this repo up on a machine that had never run chezmoi, written down for the next fresh install (e.g. the new work computer).

## nvim: check on first launch

`install.sh` clones [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) from `main`, unpinned. On 2026-09-14, upstream rewrote itself from lazy.nvim/Mason to Neovim's native `vim.pack` plugin manager — a full architecture change. Our overrides (`home/dot_config/nvim/lua/custom/plugins/ruby.lua` and `gitsigns.lua`) were verified against that new `vim.pack` structure, not the older lazy.nvim one.

Because the clone is unpinned, upstream can move again before you next run `install.sh`. First time you open `nvim` on a new machine, check:
- `:LspInfo` on a `.rb` file shows `ruby_lsp` attached
- gitsigns blame is on by default (`current_line_blame`) and `<leader>tb` toggles it

If either is missing, diff `~/.config/nvim/init.lua` against what `ruby.lua`/`gitsigns.lua` assume (see the comments in those two files for exactly what they're working around) and update them to match upstream's current structure.

## tree-sitter-cli: check for a prebuilt bottle

`Brewfile` includes `tree-sitter-cli` (kickstart's current treesitter setup needs the CLI to build parsers — the `tree-sitter` formula is just the library, not the CLI). On an older/unsupported macOS + Intel combo, Homebrew has no bottle for it and `brew install tree-sitter-cli` falls back to compiling LLVM from source as a dependency, which can run for a day or more without finishing. On a normal/current/Apple Silicon machine this should just fetch a bottle in seconds — but if `brew bundle` hangs on this formula, check `ps aux | grep clang` before assuming it's stuck, and consider skipping/backgrounding it rather than waiting.

## Everything else

`chezmoi diff` was run end-to-end against this repo (working tree, not just the last commit) before pushing and came back clean — only the expected set of files differed, nothing malformed. `install.sh`'s ordering (clone kickstart → patch in the `custom.plugins` require → `chezmoi init --apply` → `brew bundle`) was exercised as written, not just read.
