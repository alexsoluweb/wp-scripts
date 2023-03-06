#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to synchronize remote dev server 
# files and database from the local environment.
#
# Usage: ./update-dev.sh
#================================================================

#===========================
# CONFIG
#==========================
REMOTE_DOMAIN=''
REMOTE_USER=''
REMOTE_PASS=''
REMOTE_HOST=''
REMOTE_PATH=''
REMOTE_PORT='22'
#==========================


# Update plugins/themes
INFO "Updating themes/plugins..."
if [ -n "${REMOTE_PASS}" ]; then
	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete
	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --exclude node_modules --delete
else
	rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete
	rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --exclude node_modules --delete
fi


# Update database
INFO "Updating database..."
if [ -n "${REMOTE_PASS}" ]; then
	wp db export tmp.sql --allow-root --skip-plugins --skip-themes --add-drop-table
	sshpass -p ${REMOTE_PASS} scp -P ${REMOTE_PORT} tmp.sql ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp db import tmp.sql"
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/tmp.sql" && rm -f tmp.sql
else
	wp db export tmp.sql --allow-root --skip-plugins --skip-themes --add-drop-table
	scp -p ${REMOTE_PORT} tmp.sql ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp db import tmp.sql"
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/tmp.sql" && rm -f tmp.sql
fi


# Update domain
INFO "Replacing domain ${LOCAL_DOMAIN} => ${REMOTE_DOMAIN}..."
if [ -n "${REMOTE_PASS}" ]; then
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http://${LOCAL_DOMAIN}' 'https://${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http:\/\/${LOCAL_DOMAIN}' 'https:\/\/${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http%3A%2F%2F${LOCAL_DOMAIN}' 'https%3A%2F%2F${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace '${LOCAL_DOMAIN}' '${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
else
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http://${LOCAL_DOMAIN}' 'https://${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http:\/\/${LOCAL_DOMAIN}' 'https:\/\/${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http%3A%2F%2F${LOCAL_DOMAIN}' 'https%3A%2F%2F${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace '${LOCAL_DOMAIN}' '${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
fi




