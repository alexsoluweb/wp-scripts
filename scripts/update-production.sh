#!/bin/bash
set -e
source "`dirname $0`/common.sh"

# Update dependencies in composer
INFO "Updating dependencies..."
TIME_START
rsync -ave "ssh -p ${REMOTE_PORT}" composer.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/ 
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && composer update" 
TIME_STOP

# Sync. plugins
# rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/plugins/<plugin_name>/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/<plugin_name>/ --delete 

# Sync. themes
INFO "Updating themes..."
TIME_START
rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete 
TIME_STOP

INFO "Done synchronization with success"



