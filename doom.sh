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

# Install DBeaver
sudo apt-get install -y dbeaver-ce

# Get phpcs
composer global require "squizlabs/php_codesniffer=*"

# Add phpcs to path, and get the source
echo 'export PATH=~/.config/composer/vendor/bin:$PATH' >>~/.profile
source ~/.profile

# Register custom folder for phpcs to look for standards
mkdir ~/.config/composer/vendor/standards
phpcs --config-set installed_paths ~/.config/composer/vendor/standards

# Node stuff
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source ~/.profile

wait $!

# Install newest node with nvm
nvm install node



################################
#
# Install Emacs & Doom + config
#
################################

# Install emacs26 & doom
sudo apt-get install -y emacs26
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

# Add personal doom conf
cd ~/.doom.d
git clone https://github.com/teemu-nurmi/doom-conf.git
sudo cp -r doom-conf/. .
sudo rm -rf doom-conf
cd ..

# Give user ownership of doom conf
sudo chown -R $user:$user ~/.doom.d
sudo chmod -R g+rwx ~/.doom.d

# Refresh Doom
cd ~/.emacs.d
bin/doom refresh



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
chown -R $user:$user /development
chmod -R g+wrx /development

# Reboot at end of installation
sudo reboot
