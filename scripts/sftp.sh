#!/bin/bash
set -e

#=================================================
# SYNOPSYS
#=================================================

# ./sftp.sh <remote|local>

#=================================================
# CONFIG
#=================================================

# FTP login credentials
user=""
pass=""
host=""
port="22"

# Local directories to mirror (relative path)
local_dirs=("./<relative_path>")

# Remote directories to mirror
remote_dirs=("/home/$user/<absolute_path>")

#=================================================
# Begin Script
#=================================================

# Get the update direction from the command line argument
update_direction=$1

# Define the remote server URL
remote_server="sftp://$user:'$pass'@$host:$port"

# Use a for loop to update each directory
for i in "${!local_dirs[@]}"
do
  local_dir="${local_dirs[i]}"
  remote_dir="${remote_dirs[i]}"

  if [ "$update_direction" == "remote" ]; then
    # Connect to the SFTP server and mirror the local directory to the remote directory
    lftp -u $user,"$pass" -p $port sftp://$host -e "set sftp:auto-confirm yes; mirror -R --only-newer --delete ${local_dirs%/} ${remote_dirs%/}; quit"
  elif [ "$update_direction" == "local" ]; then
    # Connect to the SFTP server and mirror the remote directory to the local directory
    lftp -u $user,"$pass" -p $port sftp://$host -e "set sftp:auto-confirm yes; mirror --only-newer --delete ${remote_dirs%/} ${local_dirs%/}; quit"
  else
    # Print error message if update direction is not specified or invalid
    echo -e "\033[31mError: Invalid update direction specified. Please specify 'remote' or 'local'.\033[0m"
    exit 1
  fi
done