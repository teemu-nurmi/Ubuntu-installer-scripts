#!/usr/bin/env bash
################################
#
# Install guest additions & DE
#
# These scripts are meant to work with
# Ubuntu-server 18.04
#
################################

# U & U
apt update
apt upgrade -y

# Get essential packages
apt-get install -y build-essential dkms linux-headers-$(uname -r) software-properties-common

# Get guest additions
apt-get install -y virtualbox-guest-x11 virtualbox-guest-dkms virtualbox-guest-utils

# Install the preferred desktop environment
apt-get install -y xorg
apt-get install -y --no-install-recommends xubuntu-core

# If no development folder in root, make one
# This should be created as a partition when installing
if [[ ! -d /development ]]
then
    mkdir /development
fi

# Give user permissions to the dev folder
chown -R $USER:$USER /development
chmod -R g+wrx /development

# Get PPAs

# php & apache
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2 -y

# Emacs
add-apt-repository ppa:kelleyk/emacs

# DBeaver
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

# Update repos
apt update

# Install DBeaver
apt-get install -y dbeaver-ce

# Install FireFox
apt-get install -y firefox

# Python stuff
apt-get install -y python3-pip
apt-get install -y python3-venv

# PHP stuff
apt-get install -y composer

# Get phpcs
composer global require "squizlabs/php_codesniffer=*"

# Add phpcs to path, and get the source
echo 'export PATH="~/.composer/vendor/bin:$PATH"' >>~/.profile
source ~/.profile

# Register custom folder for phpcs to look for standards
mkdir ~/.config/composer/vendor/standards
phpcs --config-set installed_paths ~/.config/composer/vendor/standards

# Node stuff
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source ~/.profile

# Install newest node with nvm
nvm install node


################################
#
# Install LAMP stack
#
################################

apt-get install -y apache2 mariadb-server git curl redis

# Enable apache mods
a2enmod rewrite
systemctl restart apache2

# Install PHP and packages
apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-common php7.3-zip php7.3-mysql php7.3-imagick php7.3-mbstring php7.3-dom php7.3-curl php7.3-xml php7.3-redis php7.3-fpm php7.3-gd php7.3-intl php7.3-opcache php7.3-soap

# Get & install fast CGI apache module
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f

# Enable fast CGI
a2enmod actions fastcgi proxy_fcgi
systemctl restart apache2

# Add apache to user and user to apache groups
usermod -aG $USER www-data
usermod -aG www-data $USER



################################
#
# configure LAMP stack
#
################################

sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
sed -i "s#/var/www/#/development/www/#g" /etc/apache2/apache2.conf
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/apache2/php.ini

echo 'restarting apache'
service apache2 restart

echo "maxmemory 1000mb" >>/etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" >>/etc/redis/redis.conf

sed -i "s/save 900 1/#save 900 1/" /etc/redis/redis.conf
sed -i "s/save 300 10/#save 300 10/" /etc/redis/redis.conf
sed -i "s/save 60 10000/#save 60 10000/" /etc/redis/redis.conf

echo 'restarting redis'
service redis-server restart

echo 'configuring MySQL and adding a root user'
mysql -p --execute="
  CREATE USER 'larqqa'@'%' IDENTIFIED BY 'admin';
  GRANT ALL ON *.* TO 'larqqa'@'%';"

sed -i "s/bind-address = .*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "s/max_binlog_size = .*/max_binlog_size = 100M/" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "s/expire_logs_days = .*/expire_logs_days =  3/" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "/* InnoDB/a innodb_buffer_pool_size = 200M" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "/* InnoDB/a innodb_log_file_size = 100M" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "/* InnoDB/a innodb_buffer_pool_instances = 8" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "/* InnoDB/a innodb_io_capacity = 5000" /etc/mysql/mariadb.conf.d/50-server.cnf

echo 'restarting mysql'
systemctl restart mysql.service

sed -i "s/max_execution_time = .*/max_execution_time = 6000/" /etc/php/7.3/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 50M/" /etc/php/7.3/fpm/php.ini
sed -i "s/max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.3/fpm/php.ini

sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=50000/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/7.3/fpm/php.ini

sed -i "s/pm = .*/pm = static/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/pm.max_children = .*/pm.max_children = 10/" /etc/php/7.3/fpm/pool.d/www.conf

echo 'restarting fpm'
service php7.3-fpm restart

echo 'add virtual host'

sed -i "s/DirectoryIndex .*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/" /etc/apache2/mods-enabled/dir.conf

systemctl restart apache2

# Make www folder for server stuff
mkdir /development/www

# Move wordpress installer script to www folder
cp wp-install.sh /development/www

touch /etc/apache2/sites-available/lamp_server.conf

cat > /etc/apache2/sites-available/lamp_server.conf << EOL
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  ServerName lamp-server
  ServerAlias www.lamp-server.dev
  DocumentRoot /development/www/
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  <Directory /development/www/>
    AllowOverride All
  </Directory>

  <FilesMatch ".php$">
    SetHandler "proxy:unix:/var/run/php/php7.3-fpm.sock|fcgi://localhost/"
  </FilesMatch>
</VirtualHost>
EOL

a2ensite lamp_server.conf
a2dissite 000-default.conf
systemctl restart apache2

###############################
#
# Install doom as user
#
###############################

# Doom install in doom.sh file
bash doom.sh


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

# Install Wordpress if user wants to
ins=false
while true; do
read -p "Do you want to install WordPress? [y/N]
" yn
  case $yn in
    [Yy]* )
      ins=true
      break;;
    [Nn]* ) break;;
    * ) echo "Please answer y or n.";;
  esac
done

# Run wp-installer as user, not as root
if [ "$ins" = true ]; then
  cd /development/www
  bash wp-install.sh
fi

# Reboot at the end of the install
reboot
