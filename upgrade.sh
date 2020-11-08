#!/bin/bash
#==============================================================================
#TITLE:            Firefly Upgrade script
#DESCRIPTION:      script to automatically upgrade the firefly installation
#AUTHOR:           Andy Shilton
#DATE:             2020-06-06
#VERSION:          1
#USAGE:            ./upgrade.sh
#Assumptions:
# Assumes you are using Apache (lamp) to run Firefly
#
#PROCESS:
# 1 - Checks you are running as SUDO (required to create directories)
# 2 - Checks if a previous backup exists and prompts to delete it if it does
# 3 - Ask which version you want to install
# 4 - Downloads and sets up the requested version in a new directory
# 5 - runs all updates and datbase migrations
# 6 - Copies the existing installation to a backup directory call "firefly-iii-old"
# 7 - Copies the new install into the FIREFLY_DIR
# 8 - Restarts apache2 to make everything work ok
#==============================================================================
# CUSTOM SETTINGS
#==============================================================================

# directory with firefly installation in  (include trailing slash /)
FIREFLY_DIR=/var/www/firefly-iii/

#==============================================================================
# DO NOT EDIT BELOW THIS LINE
#==============================================================================
clear
# MUST be run as sudo for elevated permissions. Let's check..
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please run this script using the sudo command... Exiting."
    exit
fi

# Ask for version to install
read -p 'Which version do you want me to install?: ' VERSION


cd  ${FIREFLY_DIR}
cd ..
clear

# check if there is a previous backup and prompt to delete it
if [ -d "firefly-iii-old" ]
then
  read -p 'A previous backup exists. Continuing will delete it. Do you want to continue [y/N]? ' YESNO


if [ "$YESNO" = "y" ]; then
  rm -rf firefly-iii-old
else
  exit;
fi
fi

echo -e Installing the newer version of Firefly-iii
composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii-updated $VERSION

echo -e copying files from the older version
cp firefly-iii/.env firefly-iii-updated/.env
cp firefly-iii/storage/upload/* firefly-iii-updated/storage/upload/
cp firefly-iii/storage/export/* firefly-iii-updated/storage/export/
pwd
echo -e clearing the cache and running database migrations

cd firefly-iii-updated
rm -rf bootstrap/cache/*
php artisan cache:clear
php artisan migrate --seed
php artisan firefly-iii:upgrade-database
php artisan passport:install
php artisan cache:clear
cd ..

mv firefly-iii firefly-iii-old
mv firefly-iii-updated firefly-iii

sudo chown -R www-data:www-data firefly-iii
sudo chmod -R 775 firefly-iii/storage

echo -e Restarting the webserver
service apache2 restart
