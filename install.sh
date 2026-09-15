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

chezmoi init --apply "$(dirname "$0")"

if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
fi

if [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

brew bundle --file="$(dirname "$0")/Brewfile"
