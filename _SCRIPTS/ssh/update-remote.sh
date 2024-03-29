#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to synchronize the remote server 
# files and database with the local server.
#
# Usage: ./update-remote.sh
#================================================================


# Check required script variables
if [[ -z "$REMOTE_BACKUP_SOURCE_PATH" || -z "$REMOTE_BACKUP_DEST_PATH" ]]; then
  ERROR "Could not determine backup environment variables. Please verify $_DIR_/.env.sh"
fi


# Backup remote files
INFO "Backup remote files..."
if [ -n "$REMOTE_PASS" ]; then
	sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "tar -czf $_NOW_.tar.gz $REMOTE_BACKUP_SOURCE_PATH && mv $_NOW_.tar.gz $REMOTE_BACKUP_DEST_PATH"
else
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "tar -czf $_NOW_.tar.gz $REMOTE_BACKUP_SOURCE_PATH && mv $_NOW_.tar.gz $REMOTE_BACKUP_DEST_PATH"
fi


# Updating files
INFO "Updating files..."
if [ -n "$REMOTE_PASS" ]; then
	rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" wp-content/themes/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ --exclude-from="$_DIR_/_rsync-exclude-patterns.txt" --delete
	rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" wp-content/plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/ --exclude-from="$_DIR_/_rsync-exclude-patterns.txt" --delete
	# rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" wp-content/mu-plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/ --delete
	# rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" wp-content/uploads/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/ --delete
	# rsync -ave "sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT" wp-content/languages/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/ --delete
else
	rsync -ave "ssh -p $REMOTE_PORT" wp-content/themes/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ --exclude-from="$_DIR_/_rsync-exclude-patterns.txt" --delete
	rsync -ave "ssh -p $REMOTE_PORT" wp-content/plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/ --exclude-from="$_DIR_/_rsync-exclude-patterns.txt" --delete
	# rsync -ave "ssh -p $REMOTE_PORT" wp-content/mu-plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/ --delete
	# rsync -ave "ssh -p $REMOTE_PORT" wp-content/uploads/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/ --delete
	# rsync -ave "ssh -p $REMOTE_PORT" wp-content/languages/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/ --delete
fi


# Update database
INFO "Updating database..."
if [ -n "$REMOTE_PASS" ]; then
	wp db export - --allow-root --skip-plugins --skip-themes --add-drop-table | sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db import -"
else
	wp db export - --allow-root --skip-plugins --skip-themes --add-drop-table | ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db import -"
fi


# Update domain
INFO "Replacing domain $LOCAL_DOMAIN => $REMOTE_DOMAIN..."
if [ -n "$REMOTE_PASS" ]; then
	sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http://$LOCAL_DOMAIN' 'https://$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http:\/\/$LOCAL_DOMAIN' 'https:\/\/$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http%3A%2F%2F$LOCAL_DOMAIN' 'https%3A%2F%2F$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace '$LOCAL_DOMAIN' '$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
else
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http://$LOCAL_DOMAIN' 'https://$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http:\/\/$LOCAL_DOMAIN' 'https:\/\/$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http%3A%2F%2F$LOCAL_DOMAIN' 'https%3A%2F%2F$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace '$LOCAL_DOMAIN' '$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
fi




