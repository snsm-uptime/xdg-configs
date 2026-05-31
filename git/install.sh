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

if [[ ! -f "$DOTFILES/git/gitconfig-local" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "create stub $DOTFILES/git/gitconfig-local"
  else
    printf '%s\n' '# Empty — run ./install.sh without --skip-setup to generate from dotfiles.local.env' \
      >"$DOTFILES/git/gitconfig-local"
    log_info "Created stub git/gitconfig-local"
  fi
fi
if [[ -f "$DOTFILES/git/gitconfig-local" ]]; then
  link "$DOTFILES/git/gitconfig-local" "$XDG_CONFIG_HOME/git/gitconfig-local"
elif [[ "$DRY_RUN" == "true" ]]; then
  log_dry "ln -s $DOTFILES/git/gitconfig-local $XDG_CONFIG_HOME/git/gitconfig-local"
fi
