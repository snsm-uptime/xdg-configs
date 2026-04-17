
#   _____  ____ _ 
#  / _ \ \/ / _` |
# |  __/>  < (_| |
#  \___/_/\_\__,_|
alias exa='exa --icons'
alias l='exa -lT --level=2'
alias ll='exa -als type'
alias lt='exa -T --icons'
alias la='exa -Dxas size'
alias ls='exa -xas type'

ZSH="$XDG_DATA_HOME/zsh/oh-my-zsh"
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
ZSH_TMUX_CONFIG="$XDG_CONFIG_HOME/tmux/tmux.conf"
ZSH_TMUX_AUTOCONNECT=true
ZSH_TMUX_UNICODE=true
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode auto      # update automatically without asking
# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 14

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  alias-finder
  aliases
  brew
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

source $ZSH/oh-my-zsh.sh
source $ZDOTDIR/alias.zsh

# Must be sourced after oh-my-zsh so p10k can hook into the prompt system.
# Sourcing it here (rather than .zshenv) prevents double-loading on omz reload.
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION && "$(hostname)" == "sebassoto" ]]; then
  export EDITOR='nvim'
elif [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# required for alias-finder
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

# Created by `pipx` on 2024-07-29 08:01:35
export PATH="$PATH:/Users/sebastiansotom/.local/bin"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sebastiansotom/.docker/completions $fpath)
autoload -Uz compinit
compinit

if [[ ! "$PATH" == */home/snsm/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/snsm/.local/share/fzf/bin"
fi

source <(fzf --zsh)
[[ -f "$XDG_CONFIG_HOME/fzf/theme.sh" ]] && source "$XDG_CONFIG_HOME/fzf/theme.sh"
