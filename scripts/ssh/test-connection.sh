#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

#=================================================
# SYNOPSYS
#=================================================
# This script is used to test SSH connection to remote server
#
# Usage: ./test-connection.sh [keep|path]
#  keep: keep connection open
#  path: check remote path
#=================================================


if [ "$1" == "keep" ]; then

	INFO "Keep connection open"
	if [ -n "${REMOTE_PASS}" ]; then
		sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}
	else
		ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}
	fi
fi

if [ "$1" == "path" ]; then

	INFO "Checking remote path..."
	if [ -n "${REMOTE_PASS}" ]; then
		sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "ls -la ${REMOTE_PATH}" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
	else
		ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "ls -la ${REMOTE_PATH}" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
	fi

fi

ERROR "No action specified..."
