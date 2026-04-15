#!/usr/bin/env bash
# gh/install.sh
#
# Symlinks: $DOTFILES/gh/config/ → $XDG_CONFIG_HOME/gh/
#
# Note: hosts.yml contains OAuth tokens — add it to .gitignore if you don't
# want credentials in the repo. Track config.yml only if preferred.

mkdir -p "$XDG_CONFIG_HOME/gh"

link "$DOTFILES/gh/config.yml" "$XDG_CONFIG_HOME/gh/config.yml"
# hosts.yml contains OAuth tokens — only link if you're sure it's gitignored
# link "$DOTFILES/gh/hosts.yml" "$XDG_CONFIG_HOME/gh/hosts.yml"
