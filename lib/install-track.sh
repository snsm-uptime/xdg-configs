#!/usr/bin/env bash
# lib/install-track.sh — Record install actions for failure reports and revert

INSTALL_TRACK_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/install-logs"
INSTALL_TRACK_ID="$(date +%Y%m%d-%H%M%S)"
INSTALL_TRACK_MANIFEST=""
INSTALL_TRACK_ERRORS=""
INSTALL_TRACK_REVERT=""
INSTALL_FAILED_MODULES=()

track_init() {
  [[ "${DRY_RUN:-false}" == "true" ]] && return 0
  mkdir -p "$INSTALL_TRACK_DIR"
  INSTALL_TRACK_MANIFEST="$INSTALL_TRACK_DIR/manifest-${INSTALL_TRACK_ID}.tsv"
  INSTALL_TRACK_ERRORS="$INSTALL_TRACK_DIR/errors-${INSTALL_TRACK_ID}.log"
  INSTALL_TRACK_REVERT="$INSTALL_TRACK_DIR/revert-${INSTALL_TRACK_ID}.sh"

  cat >"$INSTALL_TRACK_MANIFEST" <<EOF
# Dotfiles install manifest — $(date -Iseconds)
# profile=${PROFILE:-custom} modules=${MODULES[*]:-}
# DOTFILES=$DOTFILES
# Revert: bash $INSTALL_TRACK_REVERT
EOF

  cat >"$INSTALL_TRACK_REVERT" <<'REVERT_HEAD'
#!/usr/bin/env bash
# Auto-generated revert script — review before running
set -euo pipefail
echo "Reverting dotfiles install..."
REVERT_HEAD
  chmod +x "$INSTALL_TRACK_REVERT"

  log_info "Install manifest: $INSTALL_TRACK_MANIFEST"
  log_info "Revert script:    $INSTALL_TRACK_REVERT"
}

track_record() {
  local kind="$1" path="$2" detail="${3:-}"
  [[ -z "$INSTALL_TRACK_MANIFEST" ]] && return 0
  printf '%s\t%s\t%s\t%s\n' "$(date -Iseconds)" "$kind" "$path" "$detail" >>"$INSTALL_TRACK_MANIFEST"

  case "$kind" in
  SYMLINK)
    {
      echo "if [[ -L \"$path\" ]]; then rm -f \"$path\"; fi"
      [[ -n "$detail" ]] && echo "# was → $detail"
    } >>"$INSTALL_TRACK_REVERT"
    ;;
  BACKUP)
    echo "# restore backup: mv \"$path\" \"${detail%%|*}\"" >>"$INSTALL_TRACK_REVERT"
    ;;
  DIR)
    echo "rm -rf \"$path\"" >>"$INSTALL_TRACK_REVERT"
    ;;
  FILE)
    echo "rm -f \"$path\"" >>"$INSTALL_TRACK_REVERT"
    ;;
  esac
}

track_module_fail() {
  local mod="$1" code="$2"
  INSTALL_FAILED_MODULES+=("$mod")
  [[ -z "$INSTALL_TRACK_ERRORS" ]] && return 0
  {
    echo "[$mod] exit=$code $(date -Iseconds)"
  } >>"$INSTALL_TRACK_ERRORS"
}

track_summary() {
  [[ -z "$INSTALL_TRACK_MANIFEST" ]] && return 0

  {
    echo ""
    echo "# install finished $(date -Iseconds)"
    if ((${#INSTALL_FAILED_MODULES[@]})); then
      echo "# FAILED modules: ${INSTALL_FAILED_MODULES[*]}"
    else
      echo "# all modules succeeded"
    fi
  } >>"$INSTALL_TRACK_MANIFEST"

  echo 'echo "Revert complete."' >>"$INSTALL_TRACK_REVERT"

  if ((${#INSTALL_FAILED_MODULES[@]})); then
    log_warn "Failed modules (${#INSTALL_FAILED_MODULES[@]}): ${INSTALL_FAILED_MODULES[*]}"
    log_warn "Errors log: $INSTALL_TRACK_ERRORS"
    return 1
  fi
  return 0
}
