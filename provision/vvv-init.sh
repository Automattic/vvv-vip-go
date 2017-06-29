#!/usr/bin/env bash

# Add GitHub and GitLab to known_hosts, so we don't get prompted
# to verify the server fingerprint.
# The fingerprints in [this repo]/ssh/known_hosts are generated as follows:
#
# As the starting point for the ssh-keyscan tool, create an ASCII file 
# containing all the hosts from which you will create the known hosts 
# file, e.g. sshhosts.
# Each line of this file states the name of a host (alias name or TCP/IP 
# address) and must be terminated with a carriage return line feed 
# (Shift + Enter), e.g.
# 
# bitbucket.org
# github.com
# gitlab.com
# 
# Execute ssh-keyscan with the following parameters to generate the file:
# 
# ssh-keyscan -t rsa,dsa -f ssh_hosts >ssh/known_hosts
# The parameter -t rsa,dsa defines the host’s key type as either rsa 
# or dsa.
# The parameter -f /home/user/ssh_hosts states the path of the source 
# file ssh_hosts, from which the host names are read.
# The parameter >ssh/known_hosts states the output path of the 
# known_host file to be created.
# 
# From "Create Known Hosts Files" at: 
# http://tmx0009603586.com/help/en/entpradmin/Howto_KHCreate.html
mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
IFS=$'\n'
for KNOWN_HOST in $(cat "${VVV_PATH_TO_SITE}/ssh/known_hosts"); do
    if ! grep -Fxq "$KNOWN_HOST" ~/.ssh/known_hosts; then
        echo $KNOWN_HOST >> ~/.ssh/known_hosts
        echo "Success: Added host to SSH known_hosts for user 'root': $(echo $KNOWN_HOST |cut -d '|' -f1)"
    fi
done

# Make a database, if we don't already have one
VIP_DB_NAME=$(echo ${VVV_SITE_NAME} | sed -e 's/[-._@#$%&*]//g')
echo -e "\nCreating database '${VVV_SITE_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${VIP_DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${VIP_DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/logs
touch ${VVV_PATH_TO_SITE}/logs/error.log
touch ${VVV_PATH_TO_SITE}/logs/access.log

# Install and configure the latest stable version of WordPress
VIP_HTDOCS="${VVV_PATH_TO_SITE}/htdocs"

# Allowed values for vip-is-multisite: true, yes, 1
VIP_IS_MULTISITE=$(get_config_value 'vip-is-multisite')
if [ "$VIP_IS_MULTISITE" == "true" ] || [ "$VIP_IS_MULTISITE" == "1" ] || [ "$VIP_IS_MULTISITE" == "yes" ]; then
    VIP_IS_MULTISITE='true';
fi
echo "Multisite: $VIP_IS_MULTISITE"

mkdir -p ${VIP_HTDOCS}
cd ${VVV_PATH_TO_SITE}/htdocs
if ! $(wp core is-installed --allow-root); then
    wp core download --path="${VVV_PATH_TO_SITE}/htdocs" --allow-root
    # Initial quick and basic config, replaced later
    wp core config --dbname="${VIP_DB_NAME}" --dbuser=wp --dbpass=wp --quiet --allow-root

    VIP_REPO=$(get_config_value 'vip-repo')
    VIP_BRANCH=$(get_config_value 'vip-branch')

    rm -rf ${VIP_HTDOCS}/wp-content/
    echo "git clone --recursive --branch ${VIP_BRANCH} ${VIP_REPO} ${VIP_HTDOCS}/wp-content/"
    git clone --recursive --branch ${VIP_BRANCH} ${VIP_REPO} ${VIP_HTDOCS}/wp-content

    rm -v "${VIP_HTDOCS}/wp-config.php"
    wp core config --dbname="${VIP_DB_NAME}" --dbuser=wp --dbpass=wp --quiet --allow-root --extra-php <<PHP
// Additional VIP Go config via vip-config.php in the
// client site repo
require_once( ABSPATH . '/wp-content/vip-config/vip-config.php' );
define( 'VIP_GO_ENV', 'vvv-local-dev' );

// With Development Mode, features that do not require a
// connection to WordPress.com servers can be activated
// on a localhost WordPress installation for testing:
// https://jetpack.com/support/development-mode/
define( 'JETPACK_DEV_DEBUG', true);

// Any additional site specific config should be
// placed in wp-content/vip-config/vip-config.php
PHP

    if [ "$VIP_IS_MULTISITE" == "true" ]; then
        wp core multisite-install --url="${VVV_SITE_NAME}.local" --quiet --title="${VVV_SITE_NAME}" --admin_name=admin --admin_email="admin@${VVV_SITE_NAME}.local" --admin_password="password" --allow-root
    else
    wp core install --url="${VVV_SITE_NAME}.local" --quiet --title="${VVV_SITE_NAME}" --admin_name=admin --admin_email="admin@${VVV_SITE_NAME}.local" --admin_password="password" --allow-root
    fi

else
    wp core update
fi

# Add MU plugins in place
if [ ! -d "${VIP_HTDOCS}/wp-content/mu-plugins" ]; then
    git clone --recursive --quiet https://github.com/Automattic/vip-go-mu-plugins.git ${VIP_HTDOCS}/wp-content/mu-plugins
    echo "Cloned the VIP Go MU plugins repository"
fi
