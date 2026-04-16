
# __  ______   ____   ____  _               _             _           
# \ \/ /  _ \ / ___| |  _ \(_)_ __ ___  ___| |_ ___  _ __(_) ___  ___ 
#  \  /| | | | |  _  | | | | | '__/ _ \/ __| __/ _ \| '__| |/ _ \/ __|
#  /  \| |_| | |_| | | |_| | | | |  __/ (__| || (_) | |  | |  __/\__ \
# /_/\_\____/ \____| |____/|_|_|  \___|\___|\__\___/|_|  |_|\___||___/
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Must be set here so zsh finds .zshrc/.zprofile in the right place.
# All other startup files are loaded automatically by zsh via ZDOTDIR.
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

#  ____  _                _      ____             __ _
# / ___|| |__   ___  _ __| |_   / ___|___  _ __  / _(_) __ _ ___
# \___ \| '_ \ / _ \| '__/ _ \___ \| | | | |
# |  __/ (_) \__ \ || (_| | | |  __/___) | |_| | |___
# |____/|_| |_|\___/|_|   \__|  \____\___/|_| |_|_| |_|\__, |___/
#                                                      |___/
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
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

#   __  __
#  / _|_  /_ __
# |  _|/ /| '_ \
# |_| /___| .__/
#         |_|
export PATH="$XDG_DATA_HOME/fzf/bin:$PATH"

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
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
