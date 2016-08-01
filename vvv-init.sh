#!/bin/bash
# Init script for a development site with a monolithic Git repo
# v1.0

# Edit these variables to suit your purposes
# ------------------------------------------

# Just a human readable description of this site
SITE_NAME="Site Name"
# The name (to be) used by MySQL for the DB
DB_NAME="site_name"
# The URL/domain for the site
SITE_URL="site-name.dev"
# The multisite stuff for wp-config.php
EXTRA_CONFIG="
// Any additional site specific config should be
// placed in vip-config/vip-config.php
"

# ----------------------------------------------------------------
# You should not need to edit below this point. Famous last words.

RED='\e[0;31m'
GREEN='\e[0;32m'
NC='\e[0m' # No Color


echo -e "${GREEN}Commencing $SITE_NAME setup${NC}"

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
for KNOWN_HOST in $(cat "ssh/known_hosts"); do
	if ! grep -Fxq "$KNOWN_HOST" ~/.ssh/known_hosts; then
	    echo $KNOWN_HOST >> ~/.ssh/known_hosts
	    echo -e "${GREEN}Success:${NC} Added host to SSH known_hosts for user 'root': $(echo $KNOWN_HOST |cut -d '|' -f1)"
	fi
done

# Make a database, if we don't already have one
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; GRANT ALL PRIVILEGES ON $DB_NAME.* TO wp@localhost IDENTIFIED BY 'wp';"

# Let's get some config in the house
if [ ! -f "htdocs/wp-config.php" ]; then
	wp --allow-root core download --path=htdocs
    # Clone the repo, if it's not there already
    rm -rf htdocs/wp-content
    cp -pr wp-content htdocs/wp-content
    echo -e "${GREEN}Success:${NC} Moved the client code repository into position"

    # Object cache drop-in
    curl -s https://raw.githubusercontent.com/Automattic/wp-memcached/master/object-cache.php > htdocs/wp-content/object-cache.php

	wp --allow-root core config --dbname="$DB_NAME" --dbuser=wp --dbpass=wp --dbhost="localhost" --extra-php <<PHP
// Additional VIP Go config via vip-config.php in the
// client site repo
require_once( ABSPATH . '/wp-content/vip-config/vip-config.php' );
define( 'VIP_GO_ENV', 'vvv-local-dev' );
$EXTRA_CONFIG
PHP
    wp --allow-root core install --url="$SITE_URL" --title="$SITE_NAME" --admin_user=wordpress --admin_password=wordpress --admin_email=info@example.invalid
    echo -e "${GREEN}Success:${NC} Installed WordPress"

    # Add MU plugins in place
    if [ ! -d "htdocs/wp-content/mu-plugins" ]; then
        git clone --recursive --quiet https://github.com/Automattic/vip-go-mu-plugins.git htdocs/wp-content/mu-plugins
        echo -e "${GREEN}Success:${NC} Cloned the VIP Go MU plugins repository"
    fi

    # Everyone gets VIP Scanner
    wp --allow-root plugin install vip-scanner
else
	echo "wp-config.php already exists for ${SITE_NAME}"
	# Make sure core and VIP Scanner are up to date
	wp --allow-root core update
    wp --allow-root plugin update vip-scanner
    echo -e "${GREEN}Success:${NC} Updated WordPress and VIP Scanner"
fi


# The Vagrant site setup script will restart Nginx for us

echo -e "${GREEN}${SITE_NAME} init is complete${NC}"
