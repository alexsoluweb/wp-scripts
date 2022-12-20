#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

# Backup local database
INFO "Backing up local database..."
TIME_START
mkdir -p ${DB_DIR}
wp db export ${DB_DIR}/${DB_FILENAME} --allow-root --skip-plugins --skip-themes --add-drop-table
TIME_STOP

# Synchronize wp-content/
INFO "Synchronizing wp-content..."
TIME_START
rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ wp-content/plugins/ --delete 
rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/mu-plugins/ wp-content/mu-plugins/ --delete 
rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ wp-content/themes/ --delete 
rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/uploads/ wp-content/uploads/ --delete 
rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/languages/ wp-content/languages/ --delete 
TIME_STOP

# Synchronize database
INFO "Synchronizing database..."
TIME_START
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp db export tmp.sql --allow-root --skip-plugins --skip-themes --add-drop-table" 
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cat ${REMOTE_PATH}/tmp.sql" | wp db import - 
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/tmp.sql" 
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
  wordfence \
  wp-offload-ses \
  wp-mail-smtp \
  wp-rocket \
TIME_STOP

INFO "Done update with success"




