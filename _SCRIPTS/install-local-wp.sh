#!/bin/bash
set -e

#================================================================
# SYNOPSYS
#================================================================
# Install or reinstall Wordpress on local server.
#
# Usage: ./install-dev.sh
#================================================================


# Environment variables
LOCAL_TLD='localhost'
PROJECT_NAME="$(basename `pwd`)"
PROJECT_DIR="/opt/lampp/htdocs/$PROJECT_NAME"
WORDPRESS_ROOT_DIR="$PROJECT_DIR/$PROJECT_NAME"
DB_NAME="$(echo wp_$PROJECT_NAME | sed 's/-/_/g')"

# Install Wordpress
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME";
wp core download --force --skip-content
wp core config --dbname="$DB_NAME"
wp core install --url="$PROJECT_NAME.$LOCAL_TLD" --title="$PROJECT_NAME"

# Create debug options
wp config set WP_DEBUG 'true' --raw
wp config set WP_DEBUG_DISPLAY 'false' --raw
wp config set SCRIPT_DEBUG 'true' --raw
wp config set WP_DEBUG_LOG $PROJECT_DIR/_LOG/wp-error.log

# Create wp-content directories
# mkdir -p $WORDPRESS_ROOT_DIR/wp-content/plugins && chmod 775 $WORDPRESS_ROOT_DIR/wp-content/plugins
# mkdir -p $WORDPRESS_ROOT_DIR/wp-content/themes && chmod 775 $WORDPRESS_ROOT_DIR/wp-content/themes
# mkdir -p $WORDPRESS_ROOT_DIR/wp-content/uploads && chmod 775 $WORDPRESS_ROOT_DIR/wp-content/uploads