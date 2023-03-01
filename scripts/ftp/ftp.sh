#!/bin/bash
set -e

#=================================================
# SYNOPSYS
#=================================================
# This script is used to mirror local and remote directories
# usage: ./ftp.sh <remote|local|test> <yes|no> [dry-run]
# remote: mirror local to remote
# local: mirror remote to local
# test: test connection
# yes: use ssl
# no: don't use ssl
# dry-run: dry run

#=================================================
# CONFIG
#=================================================

# Define the FTP login credentials
user=''
pass=''
host=''
port_number='21'

# Local directories to mirror
local_dirs="/opt/lampp/htdocs/<path>"

# Remote directories to mirror
remote_dirs="/<path>"

# Project path for yarn build
project_path='/opt/lampp/htdocs/<path>'

# Exclude build files regex
exclude_files='.*node_modules\/.*|.*\.git\/.*|.*composer\..*|.*package\..*|.*\.gitignore|.*webpack\.config\..*|.*yarn\..*|.*postcss\.config\..*|.*tailwind\.config\..*|tsconfig\.json'

# Dry run output file
dry_run_output_file="$PWD/../_LOG/ftp-dry-run.log"

#=================================================
# Begin Script
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

remote_server="ftp://$user:$pass@$host:$port_number"
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
  if [ "$project_path" != "" ]; then
    yarn --cwd $project_path build
  fi
  
  if [ "$3" == "dry-run" ]; then
    echo "Dry run mode is enabled"
    lftp -e "set ssl:verify-certificate $ssl_option; mirror --dry-run -R --delete --only-newer --exclude='$exclude_files' $local_dirs $remote_server$remote_dirs; quit" > $dry_run_output_file
  else
    echo "Updating from local path:$local_dirs to remote path:$remote_dirs ..."
    lftp -e "set ssl:verify-certificate $ssl_option; mirror -R --delete --only-newer --exclude='$exclude_files' $local_dirs $remote_server$remote_dirs; quit"
  fi
  exit 0
fi
    
# Update the local
if [ "$update_direction" == "local" ]; then
  echo "Updating from remote path:$remote_dirs to local path:$local_dirs ..."
  lftp -e  "set ssl:verify-certificate $ssl_option; mirror --delete --only-newer $remote_server$remote_dirs $local_dirs; quit"
  exit 0
fi
