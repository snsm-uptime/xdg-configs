
# __  ______   ____   ____  _               _             _           
# \ \/ /  _ \ / ___| |  _ \(_)_ __ ___  ___| |_ ___  _ __(_) ___  ___ 
#  \  /| | | | |  _  | | | | | '__/ _ \/ __| __/ _ \| '__| |/ _ \/ __|
#  /  \| |_| | |_| | | |_| | | | |  __/ (__| || (_) | |  | |  __/\__ \
# /_/\_\____/ \____| |____/|_|_|  \___|\___|\__\___/|_|  |_|\___||___/
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Source the main Zsh configuration from XDG_CONFIG_HOME
export XDG_CONFIG_HOME="$HOME/.config"
[ -f "$XDG_CONFIG_HOME/zsh/.zshrc" ] && source "$XDG_CONFIG_HOME/zsh/.zshrc"

# Source other Zsh configurations from XDG_CONFIG_HOME if they exist
[ -f "$XDG_CONFIG_HOME/zsh/.zprofile" ] && source "$XDG_CONFIG_HOME/zsh/.zprofile"
[ -f "$XDG_CONFIG_HOME/zsh/.zlogin" ] && source "$XDG_CONFIG_HOME/zsh/.zlogin"
[ -f "$XDG_CONFIG_HOME/zsh/.zlogout" ] && source "$XDG_CONFIG_HOME/zsh/.zlogout"
[ -f "$XDG_CONFIG_HOME/zsh/.p10k.zsh" ] && source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"


#  ____  _                _      ____             __ _           
# / ___|| |__   ___  _ __| |_   / ___|___  _ __  / _(_) __ _ ___ 
# \___ \| '_ \ / _ \| '__| __| | |   / _ \| '_ \| |_| |/ _` / __|
#  ___) | | | | (_) | |  | |_  | |__| (_) | | | |  _| | (_| \__ \
# |____/|_| |_|\___/|_|   \__|  \____\___/|_| |_|_| |_|\__, |___/
#                                                      |___/     
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export PYTHON_HISTORY=$XDG_STATE_HOME/python/history
export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker


#   ____                      
#  / ___|__ _ _ __ __ _  ___  
# | |   / _` | '__/ _` |/ _ \ 
# | |__| (_| | | | (_| | (_) |
#  \____\__,_|_|  \__, |\___/ 
#                 |___/       
export CARGO_HOME=$XDG_DATA_HOME/cargo
export PATH="$CARGO_HOME/bin:$PATH"

#  ____           _                 ____   ___  _     
# |  _ \ ___  ___| |_ __ _ _ __ ___/ ___| / _ \| |    
# | |_) / _ \/ __| __/ _` | '__/ _ \___ \| | | | |    
# |  __/ (_) \__ \ || (_| | | |  __/___) | |_| | |___ 
# |_|   \___/|___/\__\__, |_|  \___|____/ \__\_\_____|
#                    |___/                            
export PSQLRC="$XDG_CONFIG_HOME/pg/psqlrc"
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export PGPASSFILE="$XDG_CONFIG_HOME/pg/pgpass"
export PGSERVICEFILE="$XDG_CONFIG_HOME/pg/pg_service.conf"


#  ____                        
# |  _ \ _   _  ___ _ ____   __
# | |_) | | | |/ _ \ '_ \ \ / /
# |  __/| |_| |  __/ | | \ V / 
# |_|    \__, |\___|_| |_|\_/  
#        |___/                 
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_ROOT=$XDG_DATA_HOME/pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

#  _ ____   ___ __ ___  
# | '_ \ \ / / '_ ` _ \ 
# | | | \ V /| | | | | |
# |_| |_|\_/ |_| |_| |_|
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                      # macOS: Homebrew
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                                                # Linux: direct install
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#  _________  _   _ 
# |__  / ___|| | | |
#   / /\___ \| |_| |
#  / /_ ___) |  _  |
# /____|____/|_| |_|
# Completion files: Use XDG dirs
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION
