#!/usr/bin/env bash
# npm/install.sh — XDG npmrc

mkdir -p "$XDG_CONFIG_HOME/npm"
link "$DOTFILES/npm/npmrc" "$XDG_CONFIG_HOME/npm/npmrc"
