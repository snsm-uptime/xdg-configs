git submodule update --init --recursive

#  ____                  _     _       _
# / ___| _   _ _ __ ___ | |   (_)_ __ | | _____
# \___ \| | | | '_ ` _ \| |   | | '_ \| |/ / __|
#  ___) | |_| | | | | | | |___| | | | |   <\__ \
# |____/ \__, |_| |_| |_|_____|_|_| |_|_|\_\___/
#        |___/
ln -s ./git/config ~/.gitconfig
ln -s ./ssh/config ~/.ssh/config
ln -s ./zsh/.zshrc ~/.zshrc
ln -s ./zsh/.zshenv ~/.zshenv
ln -s ./zsh/.zprofile ~/.zprofile

source ~/.zshenv

#   ___  _     __  __       _____    _          _ _
#  / _ \| |__ |  \/  |_   _|__  /___| |__   ___| | |
# | | | | '_ \| |\/| | | | | / // __| '_ \ / _ \ | |
# | |_| | | | | |  | | |_| |/ /_\__ \ | | |  __/ | |
#  \___/|_| |_|_|  |_|\__, /____|___/_| |_|\___|_|_|
#                     |___/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
omz reload

#  _____
# |_   _| __ ___  _   ___  __
#   | || '_ ` _ \| | | \ \/ /
#   | || | | | | | |_| |>  <
#   |_||_| |_| |_|\__,_/_/\_\
git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm
