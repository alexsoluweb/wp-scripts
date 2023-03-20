#!/usr/bin/env bash
set -e

_NOW_=`date +"%Y-%m-%d__%H-%M"`

DB_DIR=../_BACKUPS
DB_FILENAME="$_NOW_.sql"

mkdir -p $DB_DIR

# Backup database
wp db export $DB_DIR/$DB_FILENAME --allow-root --skip-plugins --skip-themes --add-drop-table