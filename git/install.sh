#!/usr/bin/env bash
# git/install.sh
#
# git reads $XDG_CONFIG_HOME/git/config natively since git 2.13.
# Link each tracked file individually — no dir-level symlink.

mkdir -p "$XDG_CONFIG_HOME/git"

link "$DOTFILES/git/config"             "$XDG_CONFIG_HOME/git/config"
link "$DOTFILES/git/ignore"             "$XDG_CONFIG_HOME/git/ignore"
link "$DOTFILES/git/gitconfig-personal" "$XDG_CONFIG_HOME/git/gitconfig-personal"
link "$DOTFILES/git/gitconfig-uptime"   "$XDG_CONFIG_HOME/git/gitconfig-uptime"
