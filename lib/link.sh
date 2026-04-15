#!/usr/bin/env bash
# lib/link.sh — Safe symlink helper
#
# Usage: link <source> <target>
#   source  — absolute path inside the dotfiles repo
#   target  — absolute path where the symlink should live
#
# Behavior:
#   - If target is already a correct symlink → skip
#   - If target exists (file, dir, or wrong symlink) → backup then replace
#   - Creates parent directories as needed

# _prune_backups <target> — keep only the 3 most recent .bak-* files for <target>
_prune_backups() {
  local tgt="$1"
  local dir base
  dir="$(dirname "$tgt")"
  base="$(basename "$tgt")"
  # Backups are named <base>.bak-YYYYMMDDHHMMSS — lexicographic sort = chronological
  # Collect all but the 3 newest into an array, then delete them
  local -a stale=()
  while IFS= read -r f; do
    stale+=("$f")
  done < <(ls -1 "${dir}/${base}.bak-"[0-9]* 2>/dev/null | sort | head -n -3)
  local f
  for f in "${stale[@]+"${stale[@]}"}"; do
    rm -f "$f"
    log_info "pruned old backup: $(basename "$f")"
  done
}

link() {
  local src="$1"
  local tgt="$2"

  # Resolve to absolute path
  src="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"

  # Already linked correctly
  if [[ -L "$tgt" && "$(readlink "$tgt")" == "$src" ]]; then
    log_skip "$tgt"
    return 0
  fi

  # Something exists at target — back it up
  if [[ -e "$tgt" || -L "$tgt" ]]; then
    local bak="${tgt}.bak-$(date +%Y%m%d%H%M%S)"
    if [[ "$DRY_RUN" == "true" ]]; then
      log_dry "backup $tgt → $bak"
    else
      log_backup "$tgt → $(basename "$bak")"
      mv "$tgt" "$bak"
      _prune_backups "$tgt"
    fi
  fi

  # Create parent dir
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "ln -s $src $tgt"
  else
    mkdir -p "$(dirname "$tgt")"
    ln -s "$src" "$tgt"
    log_link "$src  →  $tgt"
  fi
}
