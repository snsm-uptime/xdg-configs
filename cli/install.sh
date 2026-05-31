#!/usr/bin/env bash
# cli/install.sh — Shell CLIs: zsh, eza

_install_eza_github() {
  local arch asset url bin_dir="$HOME/.local/bin"
  case "$ARCH" in
  x86_64) arch="x86_64" ;;
  arm64 | aarch64) arch="aarch64" ;;
  *)
    log_error "Unsupported architecture for eza GitHub install: $ARCH"
    return 1
    ;;
  esac

  # eza-community release naming (linux-gnu)
  local tag="v0.20.24"
  asset="eza_${arch}-unknown-linux-gnu.tar.gz"
  url="https://github.com/eza-community/eza/releases/download/${tag}/${asset}"

  log_info "Downloading eza from GitHub ($arch)"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "curl -fLo ... $url && tar -xzf ... -C $bin_dir"
    return 0
  fi

  mkdir -p "$bin_dir"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/eza.tar.gz"
  tar -xzf "$tmp/eza.tar.gz" -C "$tmp"
  install -m 755 "$tmp/eza" "$bin_dir/eza"
  rm -rf "$tmp"
  if declare -F track_record &>/dev/null; then
    track_record FILE "$bin_dir/eza" "eza GitHub binary"
  fi
  log_ok "eza installed to $bin_dir/eza"
}

install_eza() {
  if has eza; then
    log_skip "eza already installed"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "install eza (brew/apt/GitHub)"
    return 0
  fi

  if is_macos; then
    brew_install eza && return 0
  elif is_linux; then
    if has apt-get; then
      apt_install eza && return 0
    fi
    _install_eza_github && return 0
  fi

  log_error "Could not install eza on $OS"
  return 1
}

log_info "Installing zsh"
if is_macos; then
  brew_install zsh || log_warn "zsh install skipped"
elif is_linux; then
  apt_install zsh || log_warn "zsh install skipped"
fi

install_eza || exit 1

# Default login shell (warn on failure)
if has zsh && [[ "$DRY_RUN" == "false" ]]; then
  zsh_path="$(command -v zsh)"
  if chsh -s "$zsh_path" 2>/dev/null; then
    log_ok "Default shell set to $zsh_path"
  else
    log_warn "Could not run chsh -s $zsh_path (run manually if needed)"
  fi
elif [[ "$DRY_RUN" == "true" ]] && has zsh; then
  log_dry "chsh -s $(command -v zsh)"
fi
