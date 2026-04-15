#!/usr/bin/env bash
# nvim/install.sh
#
# Symlinks: $DOTFILES/nvim/config/ → $XDG_CONFIG_HOME/nvim/
# Neovim natively respects $XDG_CONFIG_HOME/nvim/init.lua

# nvim is a git submodule — it owns its entire directory, so we can't
# place files alongside it. Dir-level symlink is the only clean option here.
# To go fully flat, drop the submodule and track init.lua/lua/ directly.
link "$DOTFILES/nvim/config" "$XDG_CONFIG_HOME/nvim"

# ── Neovim binary ─────────────────────────────────────────────────────────────
# Bump NVIM_VERSION to upgrade. After changing the version, run:
#   curl -fsSL https://github.com/neovim/neovim/releases/download/<ver>/nvim.appimage.sha256sum
# and verify the new binary on first install.
NVIM_VERSION="v0.10.4"

if ! has nvim; then
  log_info "nvim not found — installing"
  if is_macos; then
    brew_install neovim
  elif is_linux; then
    local nvim_bin="$HOME/.local/bin/nvim"
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$HOME/.local/bin"

      # Download to a temp dir so we can verify before touching $PATH
      local nvim_tmp
      nvim_tmp="$(mktemp -d)"

      log_info "Downloading nvim $NVIM_VERSION"
      curl -fL -o "$nvim_tmp/nvim.appimage" \
        "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"
      curl -fsSL -o "$nvim_tmp/nvim.appimage.sha256sum" \
        "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage.sha256sum"

      log_info "Verifying checksum"
      if ! (cd "$nvim_tmp" && sha256sum --check nvim.appimage.sha256sum); then
        log_error "nvim checksum verification failed — aborting install"
        rm -rf "$nvim_tmp"
        exit 1
      fi

      mv "$nvim_tmp/nvim.appimage" "$nvim_bin"
      chmod u+x "$nvim_bin"
      rm -rf "$nvim_tmp"
      log_ok "nvim $NVIM_VERSION installed at $nvim_bin"
    else
      log_dry "download nvim $NVIM_VERSION AppImage → $nvim_bin (with checksum verification)"
    fi
  fi
else
  log_skip "nvim $(nvim --version | head -1) already installed"
fi
