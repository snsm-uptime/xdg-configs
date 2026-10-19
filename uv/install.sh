#!/usr/bin/env bash
# uv/install.sh — Install uv (Python package and project manager)
#
# On macOS: installed via Homebrew.
# On Linux/WSL: installed via the official standalone installer into
# ~/.local/bin (already on PATH via .zshrc), without touching shell rc files.
# https://docs.astral.sh/uv/getting-started/installation/

UV_BIN_DIR="$HOME/.local/bin"

if has uv; then
  log_skip "uv already installed → $(uv --version)"
elif is_macos; then
  brew_install uv || return 1
else
  log_info "Installing uv → $UV_BIN_DIR"
  if [[ "$DRY_RUN" == "false" ]]; then
    # UV_NO_MODIFY_PATH — rc files are symlinks into this repo; PATH is handled by .zshrc
    curl -LsSf https://astral.sh/uv/install.sh |
      UV_INSTALL_DIR="$UV_BIN_DIR" UV_NO_MODIFY_PATH=1 sh || return 1
    if declare -F track_record &>/dev/null; then
      track_record FILE "$UV_BIN_DIR/uv" "uv standalone installer"
      track_record FILE "$UV_BIN_DIR/uvx" "uv standalone installer"
    fi
    log_ok "uv installed → $("$UV_BIN_DIR/uv" --version)"
  else
    log_dry "curl astral.sh/uv/install.sh | sh (UV_INSTALL_DIR=$UV_BIN_DIR, UV_NO_MODIFY_PATH=1)"
  fi
fi
