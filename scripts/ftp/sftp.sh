#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#=================================================
# SYNOPSYS
#=================================================
# This script is used to mirror local and remote 
# directories with the sftp protocol.
#
# usage: ./sftp.sh <remote|local|test> [dry-run]
# remote: mirror local to remote
# local: mirror remote to local
# test: test connection
# dry-run: dry run
#=================================================


# Validate the first argument
if [[ "$1" != "local" && "$1" != "remote" && "$1" != "test" ]]; then
  echo -e "\033[31mError: Invalid first argument. Please specify 'local' 'remote' or 'test'.\033[0m"
  exit 1
fi

# Validate the secont argument
if [[ "$2" != "" && "$2" != "dry-run" ]]; then
  echo -e "\033[31mError: Invalid second argument. Please specify 'dry-run'.\033[0m"
  exit 1
fi

# Test the connection
if [ "$1" == "test" ]; then
  lftp -u $USER,$PASS -p $PORT sftp://$HOST -e "set sftp:auto-confirm yes; ls"
  exit 0
fi

update_direction=$1
local_dir="${local_dirs%/}/"
remote_dir="${remote_dirs%/}/"

# Update remote
if [ "$update_direction" == "remote" ]; then

  # Build the project
  if [ "$BUILD_PATH" != "" ]; then
    yarn --cwd $BUILD_PATH build
  fi

  if [ "$2" == "dry-run" ]; then
    echo "Dry run mode is enabled"
    lftp -u $USER,$PASS -p $PORT sftp://$HOST -e "set sftp:auto-confirm yes; mirror --dry-run -R --delete --only-newer --exclude='$EXCLUDE_FILES' $LOCAL_DIRS $REMOTE_DIRS; quit" > $DRY_RUN_LOG_PATH
  else
    echo "Updating from local path:$LOCAL_DIRS to remote path:$REMOTE_DIRS ..."
    lftp -u $USER,$PASS -p $PORT sftp://$HOST -e "set sftp:auto-confirm yes; mirror -R --delete --only-newer --exclude='$EXCLUDE_FILES' $LOCAL_DIRS $REMOTE_DIRS; quit"
  fi
  exit 0
fi

# Update local
if [ "$update_direction" == "local" ]; then
  echo "Updating from remote path:$REMOTE_DIRS to local path:$LOCAL_DIRS ..."
  lftp -u $USER,$PASS -p $PORT sftp://$HOST -e "set sftp:auto-confirm yes; mirror --delete --only-newer $REMOTE_DIRS $LOCAL_DIRS; quit"
  exit 0
fi