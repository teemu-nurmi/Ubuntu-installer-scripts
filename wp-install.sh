#!/bin/bash
################################
#
# Install development WordPress
#
################################

clear

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)

echo "${WHITE}
                   wwwwwwwwwwwwwwwwwwwwww
               wwwwwwwww            wwwwwwwww
            wwwwww   wwwwwwwwwwwwwwwwww   wwwwww
          wwww   wwwwwwwwwwwwwwwwwwwwwwwwww   wwww
        wwww  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww  wwww
      wwww  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww   wwww
    wwww  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww        wwww
   www  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww           www
  www          wwwwwwwwww         wwwwwwwww            www
 www  w       wwwwwwwwwwww       wwwwwwwwwww        ww  www
 ww  www       wwwwwwwwwwww       wwwwwwwwwwww      www  ww
www  www       wwwwwwwwwwwww       wwwwwwwwwwww     www  www
ww  wwwww       wwwwwwwwwwww       wwwwwwwwwwww     wwww  ww
ww  wwwwww       wwwwwwwwwwww       wwwwwwwwwwww   wwwww  ww
ww  wwwwwww      wwwwwwwwwwwww       wwwwwwwwwww  wwwwww  ww
ww  wwwwwww       wwwwwwwwwww        wwwwwwwwwww  wwwwww  ww
ww  wwwwwwww       wwwwwwwww  w       wwwwwwwww  wwwwwww  ww
ww  wwwwwwwww      wwwwwwwww www       wwwwwwww wwwwwwww  ww
www  wwwwwwww       wwwwwww wwwww      wwwwwww  wwwwwww  www
 ww  wwwwwwwww       wwwww  wwwwww      wwwww  wwwwwwww  ww
 www  wwwwwwwww      wwwww wwwwwww       wwww wwwwwwww  www
  www  wwwwwwwww      www wwwwwwwww      www  wwwwwww  www
   www  wwwwwwww       w wwwwwwwwwww      ww wwwwwww  www
    wwww  wwwwwww        wwwwwwwwwww        wwwwww  wwww
      wwww  wwwwww      wwwwwwwwwwwww      wwwww  wwww
        wwww  wwwww    wwwwwwwwwwwwwww     www  wwww
          wwww   ww    wwwwwwwwwwwwwwww       wwww
            wwwwww    wwwwwwwwwwwwwwwww   wwwwww
               wwwwwwwww            wwwwwwwww
                   wwwwwwwwwwwwwwwwwwwwww
${RESET}"
echo "${BOLD}${GREEN}
              Development WordPress Installer
${RESET}"

### GET INPUTS ###
# Defaults
default_path="wordpress"
default_dbname="wp_db_test"
default_dbuser="wp_admin"
default_dbpass="password"
default_admin="admin"
default_adminpw="admin"
default_admin_email="admin@admin.admin"
purge=false

echo "Set the path. (Default: $default_path)"
read path

# use default if empty
if test -n "$path"; then
  echo ""
else
  path=$default_path
fi

# Define default url after path is added
default_url="http://192.168.43.12/${path}"

echo "Set the database name. (Default: $default_dbname)"
read dbname

# use default if empty
if test -n "$dbname"; then
  echo ""
else
  dbname=$default_dbname
fi

echo "Set the database user. (Default: $default_dbuser)"
read dbuser

# use default if empty
if test -n "$dbuser"; then
  echo ""
else
  dbuser=$default_dbuser
fi

echo "Set the database password. (Default: $default_dbpass)"
read dbpass

# use default if empty
if test -n "$dbpass"; then
  echo ""
else
  dbpass=$default_dbpass
fi

echo "Set the url, folder is added automatically so only give ip, no slash. (Default: $default_url)"
read url

# use default if empty
if test -n "$url"; then
  url="${url}/${path}"
else
  url=$default_url
fi

echo "Set the admin. (Default: $default_admin)"
read admin

# use default if empty
if test -n "$admin"; then
  echo ""
else
  admin=$default_admin
fi

echo "Set the admin password. (Default: $default_adminpw)"
read adminpw

# use default if empty
if test -n "$adminpw"; then
  echo ""
else
  adminpw=$default_adminpw
fi

echo "Set the admin email. (Default: $default_admin_email)"
read adminemail

# use default if empty
if test -n "$adminemail"; then
  echo ""
else
  adminemail=$default_admin_email
fi

while true; do
read -p "Do you want to purge WordPress? [y/N]
" yn
  case $yn in
    [Yy]* )
      purge=true
      break;;
    [Nn]* ) break;;
    * ) echo "Please answer y or n.";;
  esac
done

while true; do
read -p "
Is this correct?
path:           $path
MySQL db name:  $dbname
MySQL user:     $dbuser
MySQL password: $dbpass
URL:            $url
admin:          $admin
admin password: $adminpw
admin email:    $adminemail
Purge WP:       $purge
Proceed to install? [y/N]
" yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer y or n.";;
  esac
done

### START INSTALL ###

echo "${BOLD}${GREEN}
Adding user to MySQL
${RESET}"

echo "MySQL root password"
read sudopw

echo "create user"
sudo mysql -p=$sudopw --execute="CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
echo "create database"
sudo mysql -p=$sudopw --execute="CREATE DATABASE $dbname DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
echo "grant access for user to database"
sudo mysql -p=$sudopw --execute="GRANT SELECT, INSERT, DELETE, CREATE, UPDATE, ALTER, DROP ON $dbname.* TO '$dbuser'@'localhost';"

echo "${BOLD}${GREEN}
Downloading WordPress
${RESET}"
wp core download --path=/development/www/$path
cd $path

echo "${BOLD}${GREEN}
Installing WordPress
${RESET}"
wp config create --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass

wp core install --url=$url --title="WordPress site" --admin_user=$admin --admin_password=$adminpw --admin_email=$adminemail --skip-email

wp config set WP_DEBUG true
wp config set FS_METHOD 'direct'

echo "${BOLD}${GREEN}
Setting Permissions
${RESET}"
# sudo chown -R www-data:www-data /development/www/$path
sudo chmod -R g+wrx /development/www/$path

if test "$purge" = true; then
echo "${BOLD}${GREEN}
Purging default WordPress data
${RESET}"
  wp site empty --uploads --yes
  wp plugin delete --all
  wp theme delete --all;
fi

echo "${BOLD}${GREEN}
### INSTALLATION COMPLETE ###
${RESET}"
