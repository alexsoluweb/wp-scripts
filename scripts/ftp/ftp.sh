#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#=================================================
# SYNOPSYS
#=================================================
# This script is used to mirror local and remote 
# directories with the ftp protocol.
#
# usage: ./ftp.sh <remote|local|test> <yes|no> [dry-run]
# remote: mirror local to remote
# local: mirror remote to local
# test: test connection
# yes: use ssl
# no: don't use ssl
# dry-run: dry run
#=================================================


# Validate the first argument
if [[ "$1" != "local" && "$1" != "remote" && "$1" != "test" ]]; then
  echo -e "\033[31mError: Invalid first argument. Please specify 'local' 'remote' or 'test'.\033[0m"
  exit 1
fi

# Validate the second argument
if [[ "$2" != "yes" && "$2" != "no" ]]; then
  echo -e "\033[31mError: Invalid second argument. Please specify 'yes' or 'no'.\033[0m"
  exit 1
fi

# Validate the third argument
if [[ "$3" != "" && "$3" != "dry-run" ]]; then
  echo -e "\033[31mError: Invalid third argument. Please specify 'dry-run'.\033[0m"
  exit 1
fi

remote_server="ftp://$USER:$PASS@$HOST:$PORT"
ssl_option=$2

# Test the connection
if [ "$1" == "test" ]; then
  lftp -d -e "set ssl:verify-certificate $ssl_option; set net:timeout 20; open $remote_server; ls"
  exit 0
fi

update_direction=$1
local_dir="${local_dirs%/}/"
remote_dir="${remote_dirs%/}/"

# Update the remote
if [ "$update_direction" == "remote" ]; then

  # Build the project
  if [ "$BUILD_PATH" != "" ]; then
    yarn --cwd $BUILD_PATH build
  fi
  
  if [ "$3" == "dry-run" ]; then
    echo "Dry run mode is enabled"
    lftp -e "set ssl:verify-certificate $ssl_option; mirror --dry-run -R --delete --only-newer --exclude='$EXCLUDE_FILES' $LOCAL_DIRS $remote_server$REMOTE_DIRS; quit" > $DRY_RUN_LOG_PATH
  else
    echo "Updating from local path:$LOCAL_DIRS to remote path:$REMOTE_DIRS ..."
    lftp -e "set ssl:verify-certificate $ssl_option; mirror -R --delete --only-newer --exclude='$EXCLUDE_FILES' $LOCAL_DIRS $remote_server$REMOTE_DIRS; quit"
  fi
  exit 0
fi
    
# Update the local
if [ "$update_direction" == "local" ]; then
  echo "Updating from remote path:$REMOTE_DIRS to local path:$LOCAL_DIRS ..."
  lftp -e  "set ssl:verify-certificate $ssl_option; mirror --delete --only-newer $remote_server$REMOTE_DIRS $LOCAL_DIRS; quit"
  exit 0
fi
