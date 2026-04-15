#!/usr/bin/env bash
# tmux/install.sh
#
# Symlinks: $DOTFILES/tmux/config/ → $XDG_CONFIG_HOME/tmux/
# TPM path is set inside tmux.conf via:
#   set-environment -g TMUX_PLUGIN_MANAGER_PATH "$XDG_DATA_HOME/tmux/plugins"

mkdir -p "$XDG_CONFIG_HOME/tmux"

link "$DOTFILES/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

# ── TPM (Tmux Plugin Manager) ─────────────────────────────────────────────────
TPM_DIR="${XDG_DATA_HOME}/tmux/plugins/tpm"

if [[ ! -d "$TPM_DIR" ]]; then
  log_info "Installing TPM → $TPM_DIR"
  if [[ "$DRY_RUN" == "false" ]]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    log_ok "TPM installed. Inside tmux run: prefix + I to fetch plugins"
  else
    log_dry "git clone tmux-plugins/tpm $TPM_DIR"
  fi
else
  log_skip "TPM already installed"
fi
