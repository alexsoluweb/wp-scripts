#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to test SSH connection to remote server.
#
# Usage: ./test-connection.sh [keep|path]
# Options:
#  keep: keep connection open
#  path: check remote path
#================================================================


# Check action
if [ "$1" == "keep" ] || [ "$1" == "path" ]; then
	INFO "Testing connection to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PORT}..."
else
	ERROR "No action specified..."
	exit 1
fi

# Keep connection open
if [ "$1" == "keep" ]; then
	INFO "Keep connection open"
	if [ -n "${REMOTE_PASS}" ]; then
		sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}
	else
		ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}
	fi
fi

# Check remote path
if [ "$1" == "path" ]; then
	INFO "Checking remote path..."
	if [ -n "${REMOTE_PASS}" ]; then
		sshpass -p ${REMOTE_PASS} ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "ls -la ${REMOTE_PATH}" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
	else
		ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "ls -la ${REMOTE_PATH}" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
	fi
fi
