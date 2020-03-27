#!/usr/bin/env bash

################################
#
# Install some stuff
#
################################

# Get username who invoked script
#[ $SUDO_USER ] && user=$SUDO_USER || user=`whoami`
user=$USER

# DBeaver
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

wait $!
sudo apt-get update

# Install DBeaver
sudo apt-get install -y dbeaver-ce

# Get phpcs
composer global require squizlabs/php_codesniffer

# Add phpcs to path, and get the source
echo 'export PATH=~/.composer/vendor/bin:$PATH' >>~/.profile
source ~/.profile

# Register custom folder for phpcs to look for standards
mkdir ~/.composer/vendor/standards
phpcs --config-set installed_paths ~/.composer/vendor/standards

# Node stuff
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
wait $!

source ~/.profile
sudo apt-get update

# Install newest node with nvm
nvm install node



################################
#
# Install Emacs & Doom + config
#
################################

# Install emacs26 & doom
sudo apt-get install -y emacs26
# git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
# ~/.emacs.d/bin/doom install

# # Add personal doom conf
# cd ~/.doom.d
# git clone https://github.com/teemu-nurmi/doom-conf.git
# sudo cp -r doom-conf/. .
# sudo rm -rf doom-conf
# cd ..

# # Give user ownership of doom conf
# sudo chown -R $user:$user ~/.doom.d
# sudo chmod -R g+rwx ~/.doom.d

# # Refresh Doom
# cd ~/.emacs.d
# bin/doom refresh



###############################
#
# configure WP-Cli
#
################################

# Get wp-cli executable
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

# Rename the wp-cli command to just wp
sudo mv wp-cli.phar /usr/local/bin/wp



# Give user ownership to the dev folder
sudo chown -R $user:$user /development
sudo chmod -R g+wrx /development

# Reboot at end of installation
sudo apt-get update
sudo apt-get upgrade -y
sudo reboot
