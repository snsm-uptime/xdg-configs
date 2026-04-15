#!/usr/bin/env bash
# update.sh — Pull latest dotfiles and re-run the installer
#
# Usage:
#   ./update.sh                    # re-installs full profile
#   ./update.sh --profile slim
#   ./update.sh --modules git,zsh
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES/lib/log.sh"

log_section "Updating dotfiles"

# Pull latest
if git -C "$DOTFILES" rev-parse --is-inside-work-tree &>/dev/null; then
  log_info "git pull"
  git -C "$DOTFILES" pull --ff-only

  # Verify GPG signature on the resulting HEAD commit.
  # %G? codes: G=good, U=good/unknown-key, B=bad, E=error/no-key, N=no signature
  _sig_status="$(git -C "$DOTFILES" log -1 --format="%G?" HEAD)"
  case "$_sig_status" in
    G)
      log_ok "GPG signature verified (trusted key)"
      ;;
    U)
      log_warn "GPG signature valid but key is not in your trusted keyring — verify manually"
      log_warn "Run: git -C $DOTFILES log -1 --show-signature"
      ;;
    B)
      log_error "BAD GPG signature on HEAD — refusing to proceed."
      log_error "Run: git -C $DOTFILES log -1 --show-signature"
      exit 1
      ;;
    E)
      log_warn "GPG key not found in keyring — cannot verify HEAD signature."
      log_warn "Import your signing key or run: git -C $DOTFILES log -1 --show-signature"
      ;;
    N)
      log_warn "HEAD commit is not GPG-signed — supply-chain verification skipped."
      log_warn "Consider signing commits: git config commit.gpgsign true"
      ;;
  esac
  unset _sig_status
else
  log_warn "Not a git repo — skipping pull"
fi

# Re-run installer with any forwarded args
log_section "Re-linking"
bash "$DOTFILES/install.sh" "$@"
