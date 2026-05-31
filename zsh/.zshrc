
ZSH="$XDG_DATA_HOME/zsh/oh-my-zsh"
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
ZSH_TMUX_CONFIG="$XDG_CONFIG_HOME/tmux/tmux.conf"
ZSH_TMUX_AUTOCONNECT=true
ZSH_TMUX_UNICODE=true
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

ENABLE_CORRECTION="true"

# Plugins (brew only on macOS)
plugins=(
  alias-finder
  aliases
  colored-man-pages
  docker
  docker-compose
  git
  git-commit
  gitignore
  man
  node
  npm
  poetry
  poetry-env
  tmux
)
if [[ "$OSTYPE" == darwin* ]]; then
  plugins=(brew "${plugins[@]}")
fi

if [[ -f "${ZSH}/oh-my-zsh.sh" ]]; then
  source "${ZSH}/oh-my-zsh.sh"
else
  echo "oh-my-zsh not found at ${ZSH} — run: ./install.sh --modules zsh" >&2
fi

source "$ZDOTDIR/alias.zsh"

[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# Preferred editor
if command -v nvim &>/dev/null; then
  if [[ -n "$SSH_CONNECTION" ]] || {
    [[ -n "${DOTFILES_EDITOR_HOSTNAME:-}" ]] && [[ "$(hostname)" == "$DOTFILES_EDITOR_HOSTNAME" ]]
  }; then
    export EDITOR='nvim'
  elif [[ -n "$SSH_CONNECTION" ]]; then
    export EDITOR='vim'
  else
    export EDITOR='nvim'
  fi
elif command -v vim &>/dev/null; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

export PATH="$PATH:$HOME/.local/bin"

if [[ "$OSTYPE" == darwin* && -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi
autoload -Uz compinit
compinit

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi
[[ -f "$XDG_CONFIG_HOME/fzf/theme.sh" ]] && source "$XDG_CONFIG_HOME/fzf/theme.sh"
