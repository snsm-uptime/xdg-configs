#!/usr/bin/env bash
# ssh/install.sh
#
# Symlinks: $DOTFILES/ssh/config/config → $HOME/.ssh/config
#
# Note: ssh does not support XDG — it always reads $HOME/.ssh/.
# We only symlink the config file, never keys or known_hosts.

# Ensure ~/.ssh exists with correct permissions
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

# Set correct permissions on the linked config
if [[ "$DRY_RUN" == "false" && -e "$HOME/.ssh/config" ]]; then
  chmod 600 "$HOME/.ssh/config"
fi
