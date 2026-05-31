#!/usr/bin/env bash
# lib/preflight.sh — Validate environment before module install

preflight() {
  local -a modules=("$@")
  local mod need_curl=false need_nvim=false

  log_section "Preflight"

  if [[ "$OS" == "unknown" ]]; then
    log_error "Unsupported OS ($(uname -s)). Use macOS, Linux, or WSL."
    exit 1
  fi

  if is_wsl; then
    log_warn "WSL detected — Neovim AppImage may need libfuse2 (installed by nvim module)"
    for mod in "${modules[@]}"; do
      [[ "$mod" == "nvim" ]] && log_warn "WSL: ensure Docker Desktop or native docker CLI if using docker module"
    done
  fi

  require_cmd bash || exit 1
  require_cmd git || exit 1

  for mod in "${modules[@]}"; do
    case "$mod" in
    nvm | nvim) need_curl=true ;;
    esac
    [[ "$mod" == "nvim" ]] && need_nvim=true
  done

  if [[ "$need_curl" == "true" ]]; then
    require_cmd curl || exit 1
  fi

  if [[ "$need_nvim" == "true" ]] && is_linux && ! has apt-get; then
    log_warn "apt-get not found — nvim AppImage install may need manual dependencies"
  fi

  local needs_brew=false needs_apt=false
  for mod in "${modules[@]}"; do
    case "$mod" in
    cli | tmux | nvm | nvim) needs_apt=true; needs_brew=true ;;
    esac
  done

  if is_macos && [[ "$needs_brew" == "true" ]] && ! has brew; then
    log_warn "Homebrew not found — some packages will be skipped (cli, tmux, nvm, nvim)"
  fi

  if is_linux && [[ "$needs_apt" == "true" ]] && ! has apt-get; then
    log_warn "apt-get not found — try installing eza/zsh manually or use GitHub binaries"
  fi

  for mod in "${modules[@]}"; do
    [[ "$mod" == "tmux" ]] && ! has tmux && log_warn "tmux binary not found — install tmux or include cli/tmux module deps"
  done

  log_ok "Preflight passed"
}

# validate_eza_for_zsh — call after cli module if zsh is in profile
validate_eza_for_zsh() {
  [[ "${DRY_RUN:-false}" == "true" ]] && return 0

  local -a modules=("$@")
  local has_zsh=false
  local mod
  for mod in "${modules[@]}"; do
    [[ "$mod" == "zsh" ]] && has_zsh=true
  done
  [[ "$has_zsh" == "false" ]] && return 0

  if has eza; then
    log_ok "eza available for zsh module"
    return 0
  fi

  log_error "zsh module requires eza but it is not installed."
  log_error "Re-run with cli module or install eza manually."
  return 1
}
