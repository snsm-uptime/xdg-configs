#!/usr/bin/env bash
# fzf/install.sh

FZF_DIR="$XDG_DATA_HOME/fzf"
FZF_THEME_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tokyonight_moon.sh"
FZF_THEME_DEST="$XDG_CONFIG_HOME/fzf/theme.sh"

if [[ ! -d "$FZF_DIR" ]]; then
  log_info "Installing fzf → $FZF_DIR"
  if [[ "$DRY_RUN" == "false" ]]; then
    git clone --depth=1 https://github.com/junegunn/fzf.git "$FZF_DIR"
    "$FZF_DIR/install" --bin
    if declare -F track_record &>/dev/null; then
      track_record DIR "$FZF_DIR" "fzf git clone"
    fi
    log_ok "fzf installed"
  else
    log_dry "git clone fzf $FZF_DIR && $FZF_DIR/install --bin"
  fi
else
  log_info "Updating fzf → $FZF_DIR"
  if [[ "$DRY_RUN" == "false" ]]; then
    git -C "$FZF_DIR" pull --rebase
    "$FZF_DIR/install" --bin
    log_ok "fzf updated"
  else
    log_dry "git -C $FZF_DIR pull --rebase && $FZF_DIR/install --bin"
  fi
fi

log_info "Linking fzf theme → $FZF_THEME_DEST"
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$(dirname "$FZF_THEME_DEST")"
  ln -sf "$FZF_THEME_SRC" "$FZF_THEME_DEST"
  if declare -F track_record &>/dev/null; then
    track_record SYMLINK "$FZF_THEME_DEST" "$FZF_THEME_SRC"
  fi
  log_ok "fzf theme linked"
else
  log_dry "ln -sf $FZF_THEME_SRC $FZF_THEME_DEST"
fi
