#!/usr/bin/env bash
# lib/os.sh — OS and architecture detection

OS=""
ARCH=""

case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
  *)      OS="unknown" ;;
esac

case "$(uname -m)" in
  x86_64)          ARCH="x86_64" ;;
  arm64 | aarch64) ARCH="arm64" ;;
  *)               ARCH="unknown" ;;
esac

export OS ARCH

is_macos() { [[ "$OS" == "macos" ]]; }
is_linux() { [[ "$OS" == "linux" ]]; }

# Check if a command exists
has() { command -v "$1" &>/dev/null; }

# macOS package manager (homebrew)
# Usage: brew_install <pkg> [version]
#   version — optional; installs <pkg>@<version> (e.g. brew_install node 18)
brew_install() {
  local pkg="$1"
  local ver="${2:-}"
  local install_arg="${pkg}${ver:+@$ver}"
  if ! has brew; then
    log_warn "Homebrew not found — skipping install of '$install_arg'"
    return 1
  fi
  if ! brew list "$pkg" &>/dev/null; then
    log_info "brew install $install_arg"
    [[ "$DRY_RUN" == "true" ]] || brew install "$install_arg"
  else
    log_skip "$pkg already installed"
  fi
}

# Linux package manager (apt fallback)
# Usage: apt_install <pkg> [version]
#   version — optional; pins to <pkg>=<version> (e.g. apt_install nginx 1.24.0-1)
apt_install() {
  local pkg="$1"
  local ver="${2:-}"
  local install_arg="${pkg}${ver:+=$ver}"
  if ! has apt-get; then
    log_warn "apt-get not found — skipping install of '$install_arg'"
    return 1
  fi
  if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
    log_info "apt-get install -y $install_arg"
    [[ "$DRY_RUN" == "true" ]] || sudo apt-get install -y "$install_arg"
  else
    log_skip "$pkg already installed"
  fi
}

# Install a package cross-platform
# Usage: pkg_install <pkg> [version]
pkg_install() {
  local pkg="$1"
  local ver="${2:-}"
  is_macos && brew_install "$pkg" "$ver" && return
  is_linux && apt_install "$pkg" "$ver" && return
  log_warn "Cannot install '$pkg': unsupported OS ($OS)"
}
