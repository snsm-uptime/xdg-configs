#!/usr/bin/env bash
# nvm/install.sh — Install nvm (Node Version Manager)
#
# NVM_DIR is set to $XDG_CONFIG_HOME/nvm in .zshenv.
# On macOS: nvm is loaded from Homebrew.
# On Linux: nvm is installed via the official install script into NVM_DIR.

NVM_INSTALL_DIR="${XDG_CONFIG_HOME}/nvm"

if is_macos; then
  brew_install nvm
else
  if [[ -s "$NVM_INSTALL_DIR/nvm.sh" ]]; then
    log_skip "nvm already installed → $NVM_INSTALL_DIR"
  else
    log_info "Installing nvm → $NVM_INSTALL_DIR"
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$NVM_INSTALL_DIR"
      # Install without modifying shell rc files — .zshenv already sources nvm
      NVM_DIR="$NVM_INSTALL_DIR" PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh)"
      log_ok "nvm installed"
    else
      log_dry "curl nvm install.sh | bash (PROFILE=/dev/null, NVM_DIR=$NVM_INSTALL_DIR)"
    fi
  fi
fi
