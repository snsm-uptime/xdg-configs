alias vim="$EDITOR"
alias vi="$EDITOR"

#  ____  ____  _   _
# / ___||  _ \| | | |
# \___ \| |_) | |_| |
#  ___) |  __/ \___/
# |____/|_|
SERVER_IP=187.124.250.74
SSH_CLAW_KEY='~/.ssh/kvm_claw'
SSH_KVM_KEY='~/.ssh/id_ed25519_uptime'
alias sshroot="ssh -i $SSH_KVM_KEY root@$SERVER_IP"
alias sshsnsm="ssh -i $SSH_KVM_KEY snsm@$SERVER_IP"
alias sshclaw="ssh -i $SSH_CLAW_KEY claw@$SERVER_IP"

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
alias cdgh='~/Documents/github/'
alias cdup='cd ~/Documents/github/uptime/'
alias cdpr='cd ~/Documents/github/personal/'
