#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

#---------------------------------------------------
# Begin Script
#---------------------------------------------------

# Synchronize databases
INFO "Synchronizing database..."
TIME_START
cat $DB_PATH | wp db import - 
TIME_STOP

# Replace domain
INFO "Replacing domain ${REMOTE_DOMAIN} => ${LOCAL_DOMAIN}..."
TIME_START
wp search-replace "https://${REMOTE_DOMAIN}" "http://${LOCAL_DOMAIN}" --all-tables --skip-plugins --skip-themes
wp search-replace "https:\/\/${REMOTE_DOMAIN}" "http:\/\/${LOCAL_DOMAIN}" --all-tables --skip-plugins --skip-themes
wp search-replace "https%3A%2F%2F${REMOTE_DOMAIN}" "http%3A%2F%2F${LOCAL_DOMAIN}" --all-tables --skip-plugins --skip-themes
wp search-replace "${REMOTE_DOMAIN}" "${LOCAL_DOMAIN}" --all-tables --skip-plugins --skip-themes
TIME_STOP

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
