#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

#=================================================
# SYNOPSYS
#=================================================
# This script is used to update the local database
# with the path to the sql file
#
# usage: ./update-local-db.sh
#=================================================

# Synchronize databases
INFO "Synchronizing database..."
cat $DB_PATH | wp db import - 

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
