#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to synchronize local files and database 
# with the remote server.
#
# Usage: ./update-local.sh
#================================================================


# Synchronize files
INFO "Synchronizing files..."
if [ -n "$REMOTE_PASS" ]; then
  rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/ wp-content/plugins/ --delete 
  rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/ wp-content/mu-plugins/ --delete 
  rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ wp-content/themes/ --delete 
  rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/ wp-content/uploads/ --delete 
  rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/ wp-content/languages/ --delete 
else
  rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/ wp-content/plugins/ --delete 
  rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/ wp-content/mu-plugins/ --delete 
  rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ wp-content/themes/ --delete 
  rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/ wp-content/uploads/ --delete 
  rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/ wp-content/languages/ --delete
fi

# Update database
INFO "Updating database..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp db export - --allow-root --skip-plugins --skip-themes --add-drop-table" | wp db import -
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp db export - --allow-root --skip-plugins --skip-themes --add-drop-table" | wp db import -
fi

# Replace domain
INFO "Replacing domain $REMOTE_DOMAIN => $LOCAL_DOMAIN..."
wp search-replace "https://$REMOTE_DOMAIN" "http://$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "https:\/\/$REMOTE_DOMAIN" "http:\/\/$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "https%3A%2F%2F$REMOTE_DOMAIN" "http%3A%2F%2F$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "$REMOTE_DOMAIN" "$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes

# Deactivate plugins
INFO "Deactivating plugins..."
wp plugin deactivate \
  --allow-root \
  --skip-plugins \
  --skip-themes \
  better-wp-security \
  ithemes-security-pro \
  all-in-one-wp-security-and-firewall \
  wordfence \
  wp-offload-ses \
  wp-mail-smtp \
  wp-mail-smtp-pro \
  wp-rocket \
  lite-speed-cache \
  login-lockdown \
  akismet \
  wp-super-cache \
  wp-super-minify \
  wp-fastest-cache \
  wp-fastest-cache-premium \
  worker \
  google-site-kit \


INFO "Done update with success"




