#!/usr/bin/env bash
# docker/install.sh
#
# Symlinks only config.json — the rest of $XDG_CONFIG_HOME/docker/ is runtime
# state (contexts, cli-plugins, etc.) that shouldn't be tracked.
#
# The template is per OS, because the credential helper and the Docker Desktop
# context differ between machines:
#   config.macos.json — osxkeychain + Docker Desktop's desktop-linux context
#   config.wsl.json   — Docker Desktop for Windows helper (desktop.exe), default context
#   config.linux.json — no credential helper, default context
# Docker Desktop writes back through the symlink (e.g. currentContext), so each
# machine only ever touches its own OS's template.
#
# WARNING: docker config.json can contain base64-encoded credentials inside
# "auths" entries (the "auth" key = base64("user:password")). Never commit a
# config.json that has populated auths. Use a credStore (e.g. osxkeychain,
# secretservice, pass) so credentials are never written to the file at all.

mkdir -p "$XDG_CONFIG_HOME/docker"

# Guard: refuse to link if embedded credentials are present in any template
for f in "$DOTFILES/docker/"config.*.json; do
  # The "auth" key inside an auths entry holds base64-encoded user:password
  if grep -q '"auth"' "$f" 2>/dev/null; then
    log_error "docker/$(basename "$f") contains embedded credentials (\"auth\" key detected)."
    log_error "Remove them and configure a credStore instead, then re-run."
    log_error "See: https://docs.docker.com/engine/reference/commandline/login/#credentials-store"
    exit 1
  fi
done

if is_macos; then
  link "$DOTFILES/docker/config.macos.json" "$XDG_CONFIG_HOME/docker/config.json"
elif is_wsl; then
  link "$DOTFILES/docker/config.wsl.json" "$XDG_CONFIG_HOME/docker/config.json"
elif is_linux; then
  link "$DOTFILES/docker/config.linux.json" "$XDG_CONFIG_HOME/docker/config.json"
else
  log_warn "docker: unsupported OS ($OS) — config.json not linked"
fi
