#!/usr/bin/env bash
# zsh/install.sh
#
# Symlinks: $DOTFILES/zsh/config/ → $XDG_CONFIG_HOME/zsh/
#           $DOTFILES/zsh/config/.zshenv → $HOME/.zshenv   (zsh always reads this first)
#
# .zshenv should export ZDOTDIR=$XDG_CONFIG_HOME/zsh so zsh finds
# .zshrc/.zprofile in the config dir rather than $HOME.

# .zshenv must live at $HOME — zsh reads it before ZDOTDIR is set.
# It should export ZDOTDIR=$XDG_CONFIG_HOME/zsh so everything else
# loads from there.
link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"

mkdir -p "$XDG_CONFIG_HOME/zsh"

link "$DOTFILES/zsh/.zshrc"    "$XDG_CONFIG_HOME/zsh/.zshrc"
link "$DOTFILES/zsh/.zprofile" "$XDG_CONFIG_HOME/zsh/.zprofile"
link "$DOTFILES/zsh/.p10k.zsh" "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
link "$DOTFILES/zsh/alias.zsh" "$XDG_CONFIG_HOME/zsh/alias.zsh"

# ── Oh My Zsh ────────────────────────────────────────────────────────────────
# Cloned directly via git rather than curl|sh to avoid remote code execution at
# install time. Git verifies every object by its SHA-1 content hash over TLS,
# giving equivalent integrity without executing a remotely fetched shell script.
ZSH_DIR="${XDG_DATA_HOME}/zsh/oh-my-zsh"

if [[ ! -d "$ZSH_DIR" ]]; then
  log_info "Installing Oh My Zsh → $ZSH_DIR"
  if [[ "$DRY_RUN" == "false" ]]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
    log_ok "Oh My Zsh installed"
  else
    log_dry "git clone --depth=1 ohmyzsh/ohmyzsh $ZSH_DIR"
  fi
else
  log_skip "Oh My Zsh already installed"
fi

# ── Powerlevel10k ─────────────────────────────────────────────────────────────
P10K_DIR="${ZSH_DIR}/custom/themes/powerlevel10k"

if [[ ! -d "$P10K_DIR" ]]; then
  log_info "Installing powerlevel10k"
  if [[ "$DRY_RUN" == "false" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    log_ok "powerlevel10k installed"
  else
    log_dry "git clone powerlevel10k $P10K_DIR"
  fi
else
  log_skip "powerlevel10k already installed"
fi
