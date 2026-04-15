#!/usr/bin/env bash
# docker/install.sh
#
# Symlinks only config.json — the rest of $XDG_CONFIG_HOME/docker/ is runtime
# state (contexts, cli-plugins, etc.) that shouldn't be tracked.
#
# WARNING: docker config.json can contain base64-encoded credentials inside
# "auths" entries (the "auth" key = base64("user:password")). Never commit a
# config.json that has populated auths. Use a credStore (e.g. osxkeychain,
# secretservice, pass) so credentials are never written to the file at all.

mkdir -p "$XDG_CONFIG_HOME/docker"

# Guard: refuse to link if embedded credentials are present
if [[ -f "$DOTFILES/docker/config.json" ]]; then
  # The "auth" key inside an auths entry holds base64-encoded user:password
  if grep -q '"auth"' "$DOTFILES/docker/config.json" 2>/dev/null; then
    log_error "docker/config.json contains embedded credentials (\"auth\" key detected)."
    log_error "Remove them and configure a credStore instead, then re-run."
    log_error "See: https://docs.docker.com/engine/reference/commandline/login/#credentials-store"
    exit 1
  fi
fi

link "$DOTFILES/docker/config.json" "$XDG_CONFIG_HOME/docker/config.json"
