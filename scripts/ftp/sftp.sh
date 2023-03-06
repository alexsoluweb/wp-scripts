#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#=================================================
# SYNOPSYS
#=================================================
# usage: ./sftp.sh <remote|local|test> [dry-run]
# remote: mirror local to remote
# local: mirror remote to local
# test: test connection
# dry-run: dry run

#=================================================
# Begin Script
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
  lftp -u $user,$pass -p $port sftp://$host -e "set sftp:auto-confirm yes; ls"
  exit 0
fi

update_direction=$1
local_dir="${local_dirs%/}/"
remote_dir="${remote_dirs%/}/"

# Update remote
if [ "$update_direction" == "remote" ]; then

  # Build the project
  if [ "$project_path" != "" ]; then
    yarn --cwd $project_path build
  fi

  if [ "$2" == "dry-run" ]; then
    echo "Dry run mode is enabled"
    lftp -u $user,$pass -p $port sftp://$host -e "set sftp:auto-confirm yes; mirror --dry-run -R --delete --only-newer --exclude='$exclude_files' $local_dirs $remote_dirs; quit" > $dry_run_output_file
  else
    echo "Updating from local path:$local_dirs to remote path:$remote_dirs ..."
    lftp -u $user,$pass -p $port sftp://$host -e "set sftp:auto-confirm yes; mirror -R --delete --only-newer --exclude='$exclude_files' $local_dirs $remote_dirs; quit"
  fi
  exit 0
fi

# Update local
if [ "$update_direction" == "local" ]; then
  echo "Updating from remote path:$remote_dirs to local path:$local_dirs ..."
  lftp -u $user,$pass -p $port sftp://$host -e "set sftp:auto-confirm yes; mirror --delete --only-newer $remote_dirs $local_dirs; quit"
  exit 0
fi