#!/usr/bin/env bash
# install.sh — Dotfiles installer
#
# Usage:
#   ./install.sh                         # installs full profile
#   ./install.sh --profile slim          # predefined profile
#   ./install.sh --modules git,tmux      # specific modules only
#   ./install.sh --profile full --dry-run
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES/lib/log.sh"
source "$DOTFILES/lib/os.sh"
source "$DOTFILES/lib/link.sh"

# ── XDG defaults ─────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export DOTFILES DRY_RUN FORCE

# ── Flags ────────────────────────────────────────────────────────────────────
PROFILE=""
MODULES=()
DRY_RUN=false
FORCE=false

usage() {
  cat <<EOF

Usage: $(basename "$0") [OPTIONS]

Options:
  -p, --profile <name>   Profile: full | slim | minimal  (default: full)
  -m, --modules <list>   Comma-separated modules, e.g. git,tmux,zsh
  -n, --dry-run          Show what would be done without changing anything
  -f, --force            Replace existing symlinks without prompting
  -h, --help             Show this help

Profiles:
EOF
  for f in "$DOTFILES/profiles/"*.txt; do
    local name mods
    name="$(basename "$f" .txt)"
    mods="$(awk '!/^[[:space:]]*#/ && NF' "$f" | tr '\n' ' ')"
    printf "  %-12s %s\n" "$name" "$mods"
  done
  echo
  cat <<EOF
Adding a new app:
  1. mkdir \$DOTFILES/<appname>
  2. drop config files in \$DOTFILES/<appname>/
  3. create \$DOTFILES/<appname>/install.sh  (add link calls)
  4. echo "<appname>" >> \$DOTFILES/profiles/full.txt
  5. ./install.sh --modules <appname>
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -p | --profile)
    PROFILE="$2"
    shift 2
    ;;
  -m | --modules)
    IFS=',' read -ra MODULES <<<"$2"
    shift 2
    ;;
  -n | --dry-run)
    DRY_RUN=true
    shift
    ;;
  -f | --force)
    FORCE=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    log_error "Unknown option: $1"
    usage
    exit 1
    ;;
  esac
done

# ── Resolve modules ───────────────────────────────────────────────────────────
load_profile() {
  local name="$1"
  # Prevent path traversal — only alphanumeric, dash, and underscore allowed
  [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]] || {
    log_error "Invalid profile name: '$name'"
    exit 1
  }
  local file="$DOTFILES/profiles/$name.txt"
  [[ -f "$file" ]] || {
    log_error "Unknown profile: $name"
    exit 1
  }
  # awk: skip comments and blank lines — portable across BSD/GNU/macOS
  awk '!/^[[:space:]]*#/ && NF' "$file"
}

if [[ -n "$PROFILE" && ${#MODULES[@]} -eq 0 ]]; then
  while IFS= read -r _mod; do MODULES+=("$_mod"); done < <(load_profile "$PROFILE")
fi

if [[ ${#MODULES[@]} -eq 0 ]]; then
  while IFS= read -r _mod; do MODULES+=("$_mod"); done < <(load_profile "full")
fi

# ── Ensure XDG dirs ──────────────────────────────────────────────────────────
[[ "$DRY_RUN" == "false" ]] &&
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"

# ── Run modules ──────────────────────────────────────────────────────────────
log_section "Dotfiles — $(is_macos && echo macOS || echo Linux) ${ARCH}"
[[ "$DRY_RUN" == "true" ]] && log_warn "Dry-run mode — no changes will be made"
log_info "Modules: ${MODULES[*]}"

for mod in "${MODULES[@]}"; do
  # Validate at use-time regardless of source (--modules flag or profile file)
  [[ "$mod" =~ ^[a-zA-Z0-9_-]+$ ]] || {
    log_error "Invalid module name: '$mod' — skipping (only alphanumeric, dash, underscore allowed)"
    continue
  }
  installer="$DOTFILES/$mod/install.sh"
  if [[ -f "$installer" ]]; then
    log_module "$mod"
    # shellcheck source=/dev/null
    source "$installer"
  else
    log_warn "No install.sh for module '$mod' — skipping"
  fi
done

log_done "Done! Open a new shell or: source \$HOME/.zshenv"
