#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  brew install chezmoi
fi

if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"
fi

# Enable loading lua/custom/plugins/*.lua (kickstart ships this commented out);
# our actual customizations (ruby_lsp, gitsigns tweaks) live there, not in init.lua.
sed -i '' "s|-- require 'custom.plugins'|require 'custom.plugins'|" "$HOME/.config/nvim/init.lua"

# dot_zshrc assumes oh-my-zsh, plus these two custom plugins (fzf-zsh-plugin
# bootstraps its own fzf binary into ~/.fzf if needed, no separate brew step).
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-zsh-plugin" ]; then
  git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git "$ZSH_CUSTOM/plugins/fzf-zsh-plugin"
fi

# `chezmoi init <path>` would git-clone this repo again into a separate
# ~/.local/share/chezmoi - a second, disconnected copy that `git pull` here
# never touches. Point chezmoi's sourceDir straight at this checkout's home/
# instead, so it's always in sync with wherever this repo actually lives.
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.config/chezmoi"
if ! grep -q "^sourceDir" "$HOME/.config/chezmoi/chezmoi.toml" 2>/dev/null; then
  printf 'sourceDir = "%s/home"\n' "$DOTFILES_DIR" >>"$HOME/.config/chezmoi/chezmoi.toml"
fi
chezmoi apply

# Point iTerm2 at the chezmoi-managed plist (home/dot_config/iterm2/) instead
# of the default ~/Library/Preferences/ location, so prefs stay tracked here.
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.config/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
fi

# nvm's installer only wires itself into shell rc files; source it and
# install a Node version now so `npm "corepack"` below has an `npm` to run.
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if ! command -v node >/dev/null 2>&1; then
  nvm install --lts
fi

if [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

brew bundle --file="$(dirname "$0")/Brewfile"
