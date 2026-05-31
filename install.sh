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
source "$DOTFILES/lib/setup-local.sh"
source "$DOTFILES/lib/preflight.sh"
source "$DOTFILES/lib/install-track.sh"

# ── XDG defaults ─────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export DOTFILES DRY_RUN FORCE SKIP_SETUP SETUP_ONLY NONINTERACTIVE

# User-local bins (eza, nvim AppImage) must be visible during install checks
export PATH="$HOME/.local/bin:$PATH"

# ── Flags ────────────────────────────────────────────────────────────────────
PROFILE=""
MODULES=()
DRY_RUN=false
FORCE=false
SKIP_SETUP=false
SETUP_ONLY=false
NONINTERACTIVE=false

usage() {
  cat <<EOF

Usage: $(basename "$0") [OPTIONS]

Options:
  -p, --profile <name>   Profile: full | slim | minimal  (default: full)
  -m, --modules <list>   Comma-separated modules, e.g. git,tmux,zsh
  -n, --dry-run          Show what would be done without changing anything
  -f, --force            Replace existing paths without backup
      --skip-setup       Skip first-run dotfiles.local.env prompts
      --setup-only       Regenerate git/ssh locals from existing env (no modules)
      --non-interactive  Skip setup prompts (implies --skip-setup)
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
  --skip-setup)
    SKIP_SETUP=true
    shift
    ;;
  --setup-only)
    SETUP_ONLY=true
    shift
    ;;
  --non-interactive)
    NONINTERACTIVE=true
    SKIP_SETUP=true
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

[[ "$NONINTERACTIVE" == "true" ]] && SKIP_SETUP=true

# Load existing local env for install scripts
[[ -f "$DOTFILES/dotfiles.local.env" ]] && set -a && source "$DOTFILES/dotfiles.local.env" && set +a

# ── Setup-only mode ───────────────────────────────────────────────────────────
if [[ "$SETUP_ONLY" == "true" ]]; then
  log_section "Setup only"
  [[ -f "$DOTFILES/dotfiles.local.env" ]] || {
    log_error "Missing $DOTFILES/dotfiles.local.env — run install without --setup-only first"
    exit 1
  }
  run_setup_local regenerate
  log_done "Local configs regenerated."
  exit 0
fi

# ── Resolve modules ───────────────────────────────────────────────────────────
load_profile() {
  local name="$1"
  [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]] || {
    log_error "Invalid profile name: '$name'"
    exit 1
  }
  local file="$DOTFILES/profiles/$name.txt"
  [[ -f "$file" ]] || {
    log_error "Unknown profile: $name"
    exit 1
  }
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

log_section "Dotfiles — $(is_macos && echo macOS || echo Linux) ${ARCH}"
[[ "$DRY_RUN" == "true" ]] && log_warn "Dry-run mode — no changes will be made"
log_info "Modules: ${MODULES[*]}"

preflight "${MODULES[@]}"
track_init

# ── First-run setup ───────────────────────────────────────────────────────────
if [[ "$SKIP_SETUP" == "false" ]]; then
  run_setup_local interactive
elif [[ -f "$DOTFILES/dotfiles.local.env" ]]; then
  run_setup_local regenerate
fi

# ── Run modules ──────────────────────────────────────────────────────────────
INSTALL_ABORT=false
for mod in "${MODULES[@]}"; do
  [[ "$mod" =~ ^[a-zA-Z0-9_-]+$ ]] || {
    log_error "Invalid module name: '$mod' — skipping"
    track_module_fail "$mod" 1
    continue
  }
  installer="$DOTFILES/$mod/install.sh"
  if [[ -f "$installer" ]]; then
    log_module "$mod"
    set +e
    # shellcheck source=/dev/null
    source "$installer"
    _mod_rc=$?
    set -e
    if [[ $_mod_rc -ne 0 ]]; then
      log_error "Module '$mod' failed (exit $_mod_rc)"
      track_module_fail "$mod" "$_mod_rc"
      INSTALL_ABORT=true
    fi
  else
    log_warn "No install.sh for module '$mod' — skipping"
  fi
done

set +e
validate_eza_for_zsh "${MODULES[@]}"
_validate_rc=$?
set -e
[[ $_validate_rc -ne 0 ]] && INSTALL_ABORT=true

if [[ "$INSTALL_ABORT" == "true" ]]; then
  track_summary || true
  log_error "Install finished with errors — see manifest and revert script above"
  exit 1
fi

track_summary || true
log_done "Done! Open a new shell or: source \$HOME/.zshenv"
