#!/usr/bin/env bash
# Bootstrap the Neovim setup on any Mac.
#   git clone <repo-url> ~/asnafi/dotfiles
#   ~/asnafi/dotfiles/install.sh
set -euo pipefail

DOTFILES="$HOME/asnafi/dotfiles"

echo "==> Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew missing. Install it first: https://brew.sh" >&2
  exit 1
fi

echo "==> Installing toolchain from Brewfile"
brew bundle --file="$DOTFILES/Brewfile"

echo "==> Linking nvim config"
CONFIG="$HOME/.config/nvim"
mkdir -p "$HOME/.config"
# Back up a real (non-symlink) existing config so nothing is lost.
if [ -e "$CONFIG" ] && [ ! -L "$CONFIG" ]; then
  backup="$CONFIG.bak.$(date +%s)"
  echo "    Existing config found -> backing up to $backup"
  mv "$CONFIG" "$backup"
fi
ln -sfn "$DOTFILES/nvim" "$CONFIG"

echo "==> Done."
echo "    1. Set your terminal font to 'JetBrainsMono Nerd Font'."
echo "    2. Launch: nvim   (LazyVim installs plugins on first run)"
echo "    3. Run :checkhealth and :LazyExtras to verify."
echo "    4. Commit the generated ~/.config/nvim/lazy-lock.json for pinned plugins."
