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


# Check required script variables
if [[ -z "$WP_ADMIN_USER" || -z "$WP_ADMIN_EMAIL" || -z "$WP_ADMIN_PASS" || -z "$WP_PREFIX" || -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
  ERROR "Could not determine Wordpress environment variables. Please verify $_DIR_/.env.sh"
fi


# Install Wordpress
INFO "Installing Wordpress..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core download --force --skip-content"
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config create --dbname='$DB_NAME' --dbuser='$DB_USER' --dbpass='$DB_PASS' --dbprefix='$WP_PREFIX'"
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core install --url='$REMOTE_DOMAIN' --title='$PROJECT_NAME' --admin_user='$WP_ADMIN_USER' --admin_email='$WP_ADMIN_EMAIL' --admin_password='$WP_ADMIN_PASS' --skip-email"
  rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" .htaccess $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/.htaccess --delete

else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core download --force --skip-content"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config create --dbname='$DB_NAME' --dbuser='$DB_USER' --dbpass='$DB_PASS' --dbprefix='$WP_PREFIX'"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core install --url='$REMOTE_DOMAIN' --title='$PROJECT_NAME' --admin_user='$WP_ADMIN_USER' --admin_email='$WP_ADMIN_EMAIL' --admin_password='$WP_ADMIN_PASS' --skip-email"
  rsync -ave "ssh -p $REMOTE_PORT" .htaccess $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/.htaccess --delete
fi

# Create subdirectories in wp-content and set permissions to 775
INFO "Add wp-content folders..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content && chmod 775 wp-content"
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/themes && chmod 775 wp-content/themes"
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/plugins && chmod 775 wp-content/plugins"
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/uploads && chmod 775 wp-content/uploads"
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/languages && chmod 775 wp-content/languages"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content && chmod 775 wp-content"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/themes && chmod 775 wp-content/themes"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/plugins && chmod 775 wp-content/plugins"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/uploads && chmod 775 wp-content/uploads"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/languages && chmod 775 wp-content/languages"
fi
