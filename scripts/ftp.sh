#!/bin/bash
set -e

#=================================================
# SYNOPSYS
#=================================================

# ./lftp.sh <remote|local> [yes|no]

#=================================================
# CONFIG
#=================================================

# FTP login credentials
user=""
pass=""
host=""
port_number="21"

# Local directories to mirror
local_dirs=("/opt/lampp/htdocs/path")

# Remote directories to mirror
remote_dirs=("/public_html")

#=================================================
# Begin Script
#=================================================

# Define the remote server URL
remote_server="ftp://$user:$pass@$host"

# Get the ssl certificate option from the command line argument, if not passed, set to yes
ssl_option=${2:-"yes"}

# Get the update direction from the command line argument
update_direction=$1

# Use a for loop to update each directory
for i in "${!local_dirs[@]}"
do
  local_dir="${local_dirs[i]}"
  remote_dir="${remote_dirs[i]}"

  if [ "$update_direction" == "remote" ]; then
    # Connect to the FTP server and mirror the local directory to the remote directory
    lftp -e "set ssl:verify-certificate $ssl_option; open -p $port_number $host; mirror -R --only-newer --delete $local_dir '$remote_server'$remote_dir; quit"
  elif [ "$update_direction" == "local" ]; then
    # Connect to the FTP server and mirror the remote directory to the local directory
    lftp -e "set ssl:verify-certificate $ssl_option; open -p $port_number $host; mirror -R --only-newer --delete '$remote_server'$remote_dir $local_dir; quit"
  else
    # Print error message if update direction is not specified or invalid
    echo -e "\033[31mError: Invalid update direction specified. Please specify 'remote' or 'local'.\033[0m"
    exit 1
  fi
done