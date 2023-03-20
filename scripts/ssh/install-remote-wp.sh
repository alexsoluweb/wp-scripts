#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to install Wordpress on remote server.
#
# Usage: ./install-dev.sh
#================================================================


# Check required remote variables
if [[ -z "$REMOTE_DOMAIN" || -z "$LOCAL_DOMAIN" || -z "$REMOTE_USER" || -z "$REMOTE_HOST" || -z "$REMOTE_PATH" || -z "$REMOTE_PORT" ]]; then
  ERROR "Could not determine local and/or remote server environment variables. Please verify $_DIR_/.env.sh"
fi

# Check required Wordpress variables
if [[ -z "$WP_ADMIN_USER" || -z "$WP_ADMIN_EMAIL" || -z "$WP_ADMIN_PASS" || -z "$WP_PREFIX" || -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
  ERROR "Could not determine Wordpress environment variables. Please verify $_DIR_/.env.sh"
fi

# Install Wordpress
INFO "Installing Wordpress..."
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core download --force --skip-content"
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config create --dbname='$DB_NAME' --dbuser=$DB_USER --dbpass='$DB_PASS' --dbprefix='$WP_PREFIX'"
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core install --url='$REMOTE_DOMAIN' --title='$PROJECT_NAME' --admin_user='$WP_ADMIN_USER' --admin_email='$WP_ADMIN_EMAIL' --admin_password='$WP_ADMIN_PASS' --skip-email"
rsync -ave "ssh -p $REMOTE_PORT" .htaccess $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/.htaccess --delete

# Create subdirectories in wp-content and set permissions to 775
INFO "Add wp-content folders..."
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content && chmod 775 wp-content"
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/themes && chmod 775 wp-content/themes"
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/plugins && chmod 775 wp-content/plugins"
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/uploads && chmod 775 wp-content/uploads"
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/languages && chmod 775 wp-content/languages"
