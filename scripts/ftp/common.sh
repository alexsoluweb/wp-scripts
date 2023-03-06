#!/usr/bin/env bash
set -e

_DIR_=`dirname "$(readlink -f "$0")"`
_FILE_=`basename $0`

function INFO {
  echo -e "\e[1;32m[${_FILE_}]\e[0m ${1}"
}

function WARNING {
  echo -e "\e[1;33m[${_FILE_}]\e[0m ${1}"
  CONFIRM && return
  exit 1
}

function ERROR {
  echo -e "\e[1;31m[${_FILE_}]\e[0m ${1}"
  exit 1
}

function TIME_START {
  t1=`date +%s.%N`
}

function TIME_STOP {
  t2=`date +%s.%N`
  dt=`echo "$t2 - $t1" | bc -l`
  dt=`echo "scale=2; $dt / 1" | bc -l`
  echo "Done in ${dt}s"
}

# Default configuration
if [ -f "$_DIR_/.env.sh" ]; then
  source $_DIR_/.env.sh
else
  ERROR "Config not found! Please create $_DIR_/.env.sh"
fi

# Check required environment variables
if [[ -z "$REMOTE_DOMAIN" || -z "$LOCAL_DOMAIN" || || -z "$DB_PATH" || -z "$user" || -z "$pass" || -z "$host" || -z "$port" || -z "$local_dirs" || -z "$remote_dirs" || -z "$project_path" ]]; then
  ERROR "Could not determine local and/or remote server environment variables. Please verify ${_DIR_}/.env.sh"
fi
