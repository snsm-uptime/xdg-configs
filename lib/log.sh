#!/usr/bin/env bash
# lib/log.sh — Color logging helpers

# Colors
_RESET='\033[0m'
_BOLD='\033[1m'
_DIM='\033[2m'
_CYAN='\033[0;36m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_RED='\033[0;31m'
_BLUE='\033[0;34m'
_MAGENTA='\033[0;35m'

log_section() { echo -e "\n${_BOLD}${_BLUE}▶ $*${_RESET}"; }
log_module()  { echo -e "\n${_BOLD}${_MAGENTA}◆ [$*]${_RESET}"; }
log_link()    { echo -e "  ${_CYAN}⟶  $*${_RESET}"; }
log_skip()    { echo -e "  ${_DIM}↷  skip: $*${_RESET}"; }
log_backup()  { echo -e "  ${_YELLOW}⚑  backup: $*${_RESET}"; }
log_ok()      { echo -e "  ${_GREEN}✓  $*${_RESET}"; }
log_warn()    { echo -e "  ${_YELLOW}⚠  $*${_RESET}"; }
log_error()   { echo -e "  ${_RED}✖  $*${_RESET}" >&2; }
log_info()    { echo -e "  ${_DIM}·  $*${_RESET}"; }
log_done()    { echo -e "\n${_BOLD}${_GREEN}✔ $*${_RESET}\n"; }
log_dry()     { echo -e "  ${_YELLOW}[dry-run]${_RESET} $*"; }
