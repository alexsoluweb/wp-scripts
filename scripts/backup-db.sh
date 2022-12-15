#!/usr/bin/env bash
set -e

DB_DIR=_db_backups
_NOW_=`date +"%Y-%m-%d@%H:%M"`
DB_FILENAME="${_NOW_}.sql"
mkdir -p ${DB_DIR}

# Backup database
wp db export ${DB_DIR}/${DB_FILENAME} --allow-root --skip-plugins --skip-themes --add-drop-table