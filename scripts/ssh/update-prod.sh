#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to update production files server from local.
#
# Usage: ./update-prod.sh
#================================================================

#===========================
# CONFIG
#===========================
REMOTE_BACKUP_SOURCE_PATH=''
REMOTE_BACKUP_DEST_PATH=''
#===========================


# Backup remote files
INFO "Backup remote files..."
if [ -n "${REMOTE_PASS}" ]; then
	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "tar -czf ${_NOW_}.tar.gz ${REMOTE_BACKUP_SOURCE_PATH} && mv ${_NOW_}.tar.gz ${REMOTE_BACKUP_DEST_PATH}"
else
	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "tar -czf ${_NOW_}.tar.gz ${REMOTE_BACKUP_SOURCE_PATH} && mv ${_NOW_}.tar.gz ${REMOTE_BACKUP_DEST_PATH}"
fi

# Update plugins/themes
INFO "Updating themes/plugins..."
if [ -n "${REMOTE_PASS}" ]; then
	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete
	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --exclude node_modules --delete
else
	rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete
	rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --exclude node_modules --delete
fi

# Update dependencies with composer
# INFO "Updating dependencies..."
# if [ -n "${REMOTE_PASS}" ]; then
# 	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" composer.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/ 
# 	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && composer update"
# else
# 	rsync -ave "ssh -p ${REMOTE_PORT}" composer.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/ 
# 	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && composer update"
# fi




