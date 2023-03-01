#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"


# Backup local database
# INFO "Backing up local database..."
# TIME_START
# wp db export ../_BACKUPS/${_DB_FILENAME_} --allow-root --skip-plugins --skip-themes --add-drop-table
# TIME_STOP

# Synchronize wp-content/
INFO "Synchronizing wp-content..."
TIME_START
if [ -n "${REMOTE_PASS}" ]; then
    rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ wp-content/plugins/ --delete 
    rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/mu-plugins/ wp-content/mu-plugins/ --delete 
    rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ wp-content/themes/ --delete 
    rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/uploads/ wp-content/uploads/ --delete 
    rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/languages/ wp-content/languages/ --delete 
else
  rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ wp-content/plugins/ --delete 
  rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/mu-plugins/ wp-content/mu-plugins/ --delete 
  rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ wp-content/themes/ --delete 
  rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/uploads/ wp-content/uploads/ --delete 
  rsync -ave "ssh -p ${REMOTE_PORT}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/languages/ wp-content/languages/ --delete
fi
TIME_STOP

# Synchronize database
INFO "Synchronizing database..."
if [ -n "${REMOTE_PASS}" ]; then
  sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp db export tmp.sql --allow-root --skip-plugins --skip-themes --add-drop-table" 
  sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cat ${REMOTE_PATH}/tmp.sql" | wp db import - 
  sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/tmp.sql" 
else
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp db export tmp.sql --allow-root --skip-plugins --skip-themes --add-drop-table" 
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cat ${REMOTE_PATH}/tmp.sql" | wp db import - 
  ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/tmp.sql"
fi
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




