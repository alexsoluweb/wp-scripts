#!/usr/bin/env bash
set -e

_DIR_=`dirname "$(readlink -f "$0")"`
_FILE_=`basename $0`
_NOW_=`date +"%Y-%m-%d@%H:%M"`
_DB_FILENAME_=${_NOW_}.sql

# Helpers
function CONFIRM {
    read -r -p "${1:-Are you sure?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

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
if [ -f "${_DIR_}/.env.sh" ]; then
  source ${_DIR_}/.env.sh
else
  ERROR "Config not found! Please create ${_DIR_}/.env.sh"
fi

# Change to project root directory
cd ${_DIR_}/..

# Determine local domain if not defined
if [[ -z "${LOCAL_DOMAIN}" || ${LOCAL_DOMAIN} == "" ]]; then
{
  LOCAL_DOMAIN=${REMOTE_DOMAIN#www.}
  LOCAL_DOMAIN="${LOCAL_DOMAIN%%.*}.${LOCAL_TLD-localhost}"
}
fi

# Check required environment variables
if [[ -z "${REMOTE_DOMAIN}" || -z "${LOCAL_DOMAIN}" || -z "${REMOTE_USER}" || -z "${REMOTE_HOST}" || -z "${REMOTE_PATH}" || -z "${REMOTE_PORT}" ]]; then
  ERROR "Could not determine local and/or remote server environment variables. Please verify ${_DIR_}/.env.sh"
fi
