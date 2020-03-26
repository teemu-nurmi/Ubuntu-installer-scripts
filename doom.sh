#!/usr/bin/env bash

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
sudo chown -R $USER:$USER ~/.doom.d
sudo chmod -R g+rwx ~/.doom.d

# Refresh Doom
cd ~/.emacs.d
bin/doom refresh
