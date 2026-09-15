#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  brew install chezmoi
fi

chezmoi init --apply "$(dirname "$0")"

brew bundle --file="$(dirname "$0")/Brewfile"
