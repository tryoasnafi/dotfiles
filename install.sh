#!/usr/bin/env bash
# Bootstrap the Neovim setup on macOS or Debian/Ubuntu.
#   git clone <repo-url> ~/asnafi/dotfiles
#   ~/asnafi/dotfiles/install.sh
set -euo pipefail

DOTFILES="$HOME/asnafi/dotfiles"

have() { command -v "$1" >/dev/null 2>&1; }

# --------------------------------------------------------------------- macOS
install_macos() {
  echo "==> macOS: installing toolchain from Brewfile"
  if ! have brew; then
    echo "Homebrew missing. Install it first: https://brew.sh" >&2
    exit 1
  fi
  brew bundle --file="$DOTFILES/Brewfile"
}

# ----------------------------------------------------------------- Debian/apt
# The Brewfile is Homebrew-only. On Debian the same toolset is installed, but
# apt package names differ and a few tools aren't in the repos at a usable
# version (neovim is too old for LazyVim; lazygit/glab are absent), so those
# come from upstream release tarballs instead.

# Packages that ARE in the apt repos at a usable version.
APT_PKGS=(git ripgrep fzf fd-find curl unzip tar ca-certificates gnupg fontconfig)

# Latest semver (no leading 'v') from a GitHub repo's releases/latest.
gh_latest() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep -m1 '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/'
}

# Download tarball $1, extract, install the binary named $2 into /usr/local/bin.
install_tarball_bin() {
  local url="$1" bin="$2" tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$url" | tar -xz -C "$tmp"
  $SUDO install -m755 "$(find "$tmp" -type f -name "$bin" | head -1)" /usr/local/bin/"$bin"
  rm -rf "$tmp"
}

install_debian() {
  # Run privileged steps via sudo, unless already root (minimal containers).
  SUDO=""
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"

  # Map machine arch to each project's release-asset naming.
  local nvim_arch lg_arch glab_arch
  case "$(uname -m)" in
    x86_64|amd64)  nvim_arch=x86_64; lg_arch=x86_64; glab_arch=amd64 ;;
    aarch64|arm64) nvim_arch=arm64;  lg_arch=arm64;  glab_arch=arm64 ;;
    *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
  esac

  echo "==> Debian: installing apt packages"
  $SUDO apt-get update
  $SUDO apt-get install -y "${APT_PKGS[@]}"

  # Debian ships fd as 'fdfind'; LazyVim looks for 'fd'.
  if ! have fd && have fdfind; then
    $SUDO ln -sfn "$(command -v fdfind)" /usr/local/bin/fd
  fi

  # neovim: apt's build is too old for LazyVim -> upstream tarball into /opt.
  if ! have nvim; then
    echo "==> Installing neovim (upstream)"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz" \
      | $SUDO tar -xz -C /opt
    $SUDO ln -sfn "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/local/bin/nvim
  fi

  # lazygit: not in apt -> GitHub release tarball.
  if ! have lazygit; then
    echo "==> Installing lazygit (upstream)"
    local v; v="$(gh_latest jesseduffield/lazygit)"
    install_tarball_bin \
      "https://github.com/jesseduffield/lazygit/releases/download/v${v}/lazygit_${v}_Linux_${lg_arch}.tar.gz" \
      lazygit
  fi

  # glab: not in apt -> GitLab release tarball.
  if ! have glab; then
    echo "==> Installing glab (upstream)"
    local v; v="$(curl -fsSL 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest' \
      | grep -o '"tag_name":"[^"]*"' | head -1 | sed -E 's/.*"v?([^"]+)".*/\1/')"
    install_tarball_bin \
      "https://gitlab.com/gitlab-org/cli/-/releases/v${v}/downloads/glab_${v}_linux_${glab_arch}.tar.gz" \
      glab
  fi

  # WezTerm: official apt repo (amd64 only).
  if ! have wezterm; then
    if [ "$glab_arch" = "amd64" ]; then
      echo "==> Installing WezTerm (apt repo)"
      curl -fsSL https://apt.fury.io/wez/gpg.key \
        | $SUDO gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
      echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
        | $SUDO tee /etc/apt/sources.list.d/wezterm.list >/dev/null
      $SUDO apt-get update && $SUDO apt-get install -y wezterm
    else
      echo "    WezTerm apt repo is amd64-only; skipping (install manually if needed)."
    fi
  fi

  # JetBrainsMono Nerd Font -> user font dir.
  local fontdir="$HOME/.local/share/fonts"
  if [ ! -e "$fontdir/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "==> Installing JetBrainsMono Nerd Font"
    mkdir -p "$fontdir"
    local tmp; tmp="$(mktemp -d)"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o "$tmp/JBM.zip"
    unzip -oq "$tmp/JBM.zip" -d "$fontdir" -x '*.md' '*LICENSE*'
    fc-cache -f "$fontdir" >/dev/null
    rm -rf "$tmp"
  fi
}

# -------------------------------------------------------------------- shared
link_nvim() {
  echo "==> Linking nvim config"
  local config="$HOME/.config/nvim"
  mkdir -p "$HOME/.config"
  # Back up a real (non-symlink) existing config so nothing is lost.
  if [ -e "$config" ] && [ ! -L "$config" ]; then
    local backup
    backup="$config.bak.$(date +%s)"
    echo "    Existing config found -> backing up to $backup"
    mv "$config" "$backup"
  fi
  ln -sfn "$DOTFILES/nvim" "$config"
}

# ---------------------------------------------------------------------- main
case "$(uname -s)" in
  Darwin) install_macos ;;
  Linux)
    if have apt-get; then
      install_debian
    else
      echo "This script only supports Debian/apt-based Linux." >&2
      exit 1
    fi
    ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

link_nvim

echo "==> Done."
echo "    1. Set your terminal font to 'JetBrainsMono Nerd Font'."
echo "    2. Launch: nvim   (LazyVim installs plugins on first run)"
echo "    3. Run :checkhealth and :LazyExtras to verify."
echo "    4. Commit the generated ~/.config/nvim/lazy-lock.json for pinned plugins."
