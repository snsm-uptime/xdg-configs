#!/usr/bin/env bash
# ssh/install.sh
#
# Symlinks: $DOTFILES/ssh/config/config → $HOME/.ssh/config
#
# Note: ssh does not support XDG — it always reads $HOME/.ssh/.
# We only symlink the config file, never keys or known_hosts.

# Stub local include target if setup was skipped
if [[ ! -f "$DOTFILES/ssh/config.local" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "create stub $DOTFILES/ssh/config.local"
  else
    printf '%s\n' '# Empty — run ./install.sh without --skip-setup to generate from dotfiles.local.env' \
      >"$DOTFILES/ssh/config.local"
    chmod 600 "$DOTFILES/ssh/config.local"
    log_info "Created stub ssh/config.local"
  fi
fi

# Ensure ~/.ssh exists with correct permissions
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

link "$DOTFILES/ssh/config" "$HOME/.ssh/config"
# Include config.local resolves under ~/.ssh/, not next to the repo file
link "$DOTFILES/ssh/config.local" "$HOME/.ssh/config.local"

# Set correct permissions on the linked config
if [[ "$DRY_RUN" == "false" && -e "$HOME/.ssh/config" ]]; then
  chmod 600 "$HOME/.ssh/config"
fi
