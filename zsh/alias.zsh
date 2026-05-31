alias vim="$EDITOR"
alias vi="$EDITOR"

#  ____  ____  _   _
# / ___||  _ \| | | |
# \___ \| |_) | |_| |
#  ___) |  __/ \___/
# |____/|_|
if [[ -n "${DOTFILES_SSH_SERVER_IP:-}" && -n "${DOTFILES_SSH_KEY_KVM:-}" ]]; then
  alias sshroot='ssh dotfiles-kvm-root'
  alias sshsnsm='ssh dotfiles-kvm-snsm'
fi

#  _____    _ _ _      ____             __ _
# | ____|__| (_) |_   / ___|___  _ __  / _(_) __ _ ___
# |  _| / _` | | __| | |   / _ \| '_ \| |_| |/ _` / __|
# | |__| (_| | | |_  | |__| (_) | | | |  _| | (_| \__ \
# |_____\__,_|_|\__|  \____\___/|_| |_|_| |_|\__, |___/
#                                            |___/
edit_config_file() {
    local file="$XDG_CONFIG_HOME/$1"
    $EDITOR "$file"
}

alias ealias='edit_config_file "zsh/alias.zsh" && omz reload'
alias eze='edit_config_file "zsh/.zshenv" && omz reload'
alias ezsh='edit_config_file "zsh/.zshrc" && omz reload'
alias etmx='edit_config_file "tmux/tmux.conf"'
alias egit='edit_config_file "git/config"'
alias egitp='edit_config_file "git/gitconfig-personal"'
alias egitu='edit_config_file "git/gitconfig-uptime"'

#  _____  ____ _  (eza — requires cli module)
#  / _ \ \/ / _` |
# |  __/>  < (_| |
#  \___/_/\_\__,_|
if command -v eza &>/dev/null; then
  alias eza='eza --icons=always'
  alias l='eza -l --tree --level=2 --icons=always'
  alias ll='eza -al --sort=type --icons=always'
  alias lt='eza --tree --icons=always'
  alias la='eza -D -a --sort=size --icons=always'
  alias ls='eza -a --sort=type --icons=always'
fi

#  ____             _
# |  _ \  ___   ___| | _____ _ __
# | | | |/ _ \ / __| |/ / _ \ '__|
# | |_| | (_) | (__|   <  __/ |
# |____/ \___/ \___|_|\_\___|_|
alias compdev='docker compose -f docker-compose.dev.yml up -d --build'
alias compprod='docker compose up -d --build'

#  _____     _     _
# |  ___|__ | | __| | ___ _ __ ___
# | |_ / _ \| |/ _` |/ _ \ '__/ __|
# |  _| (_) | | (_| |  __/ |  \__ \
# |_|  \___/|_|\__,_|\___|_|  |___/
if [[ -n "${DOTFILES_GITHUB_ROOT:-}" ]]; then
  alias cdgh="cd ${DOTFILES_GITHUB_ROOT}"
  alias cdup="cd ${DOTFILES_GITHUB_ROOT}/uptime"
  alias cdpr="cd ${DOTFILES_GITHUB_ROOT}/personal"
fi
