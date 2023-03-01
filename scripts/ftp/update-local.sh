#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

#---------------------------------------------------
# Configuration
#---------------------------------------------------

# Local server (optional)
LOCAL_DOMAIN=''

# Remote server
REMOTE_DOMAIN=''

# Exported database name
DB_NAME=''

#---------------------------------------------------
# Main
#---------------------------------------------------

# Synchronize databases
INFO "Synchronizing database..."
TIME_START
cat ../_BACKUPS/$DB_NAME | wp db import - 
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
TIME_START
wp plugin deactivate \
  ithemes-security-pro \
  all-in-one-wp-security-and-firewall \
  wordfence \
  wp-offload-ses \
  wp-mail-smtp \
  wp-rocket \
  login-lockdown \
  akismet \
TIME_STOP

INFO "Done update with success"
