#!/usr/bin/env bash
# fzf/install.sh

FZF_DIR="$XDG_DATA_HOME/fzf"
FZF_THEME_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tokyonight_moon.sh"
FZF_THEME_DEST="$XDG_CONFIG_HOME/fzf/theme.sh"

if [[ ! -x "$FZF_DIR/bin/fzf" ]]; then
  log_info "Installing fzf → $FZF_DIR"
  if [[ "$DRY_RUN" == "false" ]]; then
    [[ ! -d "$FZF_DIR" ]] && git clone --depth=1 https://github.com/junegunn/fzf.git "$FZF_DIR"
    "$FZF_DIR/install"
    log_ok "fzf installed"
  else
    log_dry "git clone fzf $FZF_DIR && $FZF_DIR/install --bin"
  fi
else
  log_skip "fzf already installed"
fi

log_info "Linking fzf theme → $FZF_THEME_DEST"
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$(dirname "$FZF_THEME_DEST")"
  ln -sf "$FZF_THEME_SRC" "$FZF_THEME_DEST"
  log_ok "fzf theme linked"
else
  log_dry "ln -sf $FZF_THEME_SRC $FZF_THEME_DEST"
fi
