#!/usr/bin/env bash
# nvim/install.sh
#
# Symlinks: $DOTFILES/nvim/config/ → $XDG_CONFIG_HOME/nvim/
# Neovim natively respects $XDG_CONFIG_HOME/nvim/init.lua

link "$DOTFILES/nvim/config" "$XDG_CONFIG_HOME/nvim"

# ── Submodules ────────────────────────────────────────────────────────────────
if [[ -z "$(ls -A "$DOTFILES/nvim/config" 2>/dev/null)" ]]; then
  log_info "Initializing nvim submodule (LazyVim starter)"
  if [[ "$DRY_RUN" == "false" ]]; then
    git -C "$DOTFILES" submodule sync nvim/config
    git -C "$DOTFILES" submodule update --init --recursive
    log_ok "nvim submodule initialized"
  else
    log_dry "git submodule sync nvim/config && git submodule update --init --recursive"
  fi
else
  log_skip "nvim submodule already initialized"
fi

_nvim_appimage_asset() {
  case "$ARCH" in
  x86_64) echo "nvim-linux-x86_64.appimage" ;;
  arm64 | aarch64) echo "nvim-linux-arm64.appimage" ;;
  *)
    log_error "Unsupported architecture for nvim AppImage: $ARCH"
    return 1
    ;;
  esac
}

_nvim_release_digest() {
  local asset="$1"
  curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/latest" |
    python3 -c "
import json, sys
asset = sys.argv[1]
data = json.load(sys.stdin)
for a in data.get('assets', []):
    if a.get('name') == asset:
        d = a.get('digest', '')
        print(d.removeprefix('sha256:') if d else '')
        break
" "$asset" 2>/dev/null
}

_nvim_install_appimage() {
  local asset expected actual base nvim_bin="$HOME/.local/bin/nvim"
  asset="$(_nvim_appimage_asset)" || return 1
  base="https://github.com/neovim/neovim/releases/latest/download"

  if is_wsl; then
    apt_install libfuse2 || log_warn "libfuse2 install failed — AppImage may not run on WSL"
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "download $base/$asset + verify GitHub release digest → $nvim_bin"
    return 0
  fi

  expected="$(_nvim_release_digest "$asset")"
  if [[ -z "$expected" ]]; then
    log_error "Could not fetch SHA-256 digest for $asset from GitHub API"
    return 1
  fi

  mkdir -p "$HOME/.local/bin"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$base/$asset" -o "$tmp/$asset"
  actual="$(sha256sum "$tmp/$asset" | awk '{print $1}')"
  if [[ "$actual" != "$expected" ]]; then
    log_error "nvim AppImage SHA-256 mismatch (expected $expected, got $actual)"
    rm -rf "$tmp"
    return 1
  fi
  install -m 755 "$tmp/$asset" "$nvim_bin"
  rm -rf "$tmp"
  if declare -F track_record &>/dev/null; then
    track_record FILE "$nvim_bin" "nvim AppImage"
  fi
  log_ok "nvim installed at $nvim_bin (checksum verified)"
}

# ── Neovim binary ─────────────────────────────────────────────────────────────
if ! has nvim; then
  log_info "nvim not found — installing"
  if is_macos; then
    brew_install neovim
  elif is_linux; then
    _nvim_install_appimage
  fi
else
  log_skip "nvim $(nvim --version | head -1) already installed"
fi
