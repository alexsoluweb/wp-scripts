#!/bin/bash
set -e
source "`dirname $0`/common.sh"


# Update plugins/themes
INFO "Updating themes..."
TIME_START
if [ -n "${REMOTE_PASS}" ]; then
	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete
	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --exclude node_modules --delete
else
	rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --exclude node_modules --delete
	rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --exclude node_modules --delete
fi
TIME_STOP

# Update dependencies with composer
# INFO "Updating dependencies..."
# TIME_START
# if [ -n "${REMOTE_PASS}" ]; then
# 	rsync -ave "sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT}" composer.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/ 
# 	sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && composer update"
# else
# 	rsync -ave "ssh -p ${REMOTE_PORT}" composer.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/ 
# 	ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && composer update"
# fi
# TIME_STOP


INFO "Done synchronization with success"



