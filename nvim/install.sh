#!/usr/bin/env bash
# nvim/install.sh
#
# Symlinks: $DOTFILES/nvim/config/ → $XDG_CONFIG_HOME/nvim/
# Neovim natively respects $XDG_CONFIG_HOME/nvim/init.lua

# nvim is a git submodule — it owns its entire directory, so we can't
# place files alongside it. Dir-level symlink is the only clean option here.
# To go fully flat, drop the submodule and track init.lua/lua/ directly.
link "$DOTFILES/nvim/config" "$XDG_CONFIG_HOME/nvim"

# ── Submodules ────────────────────────────────────────────────────────────────
if [[ -z "$(ls -A "$DOTFILES/nvim/config")" ]]; then
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

# ── Neovim binary ─────────────────────────────────────────────────────────────
if ! has nvim; then
  log_info "nvim not found — installing"
  if is_macos; then
    brew_install neovim
  elif is_linux; then
    nvim_bin="$HOME/.local/bin/nvim"
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$HOME/.local/bin"
      curl -fLo "$nvim_bin" \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
      chmod u+x "$nvim_bin"
      log_ok "nvim installed at $nvim_bin"
    else
      log_dry "download nvim AppImage → $nvim_bin"
    fi
  fi
else
  log_skip "nvim $(nvim --version | head -1) already installed"
fi
