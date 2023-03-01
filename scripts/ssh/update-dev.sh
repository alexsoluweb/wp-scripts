#!/bin/bash
set -e
source "`dirname $0`/common.sh"


# Install Wordpress
INFO "Installing Wordpress..."
TIME_START
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp core download --force --skip-content"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp config create --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASS}"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp core install --url=${REMOTE_DOMAIN} --title=${PROJECT_NAME} --admin_user=${WP_ADMIN_USER} --admin_email=${WP_ADMIN_EMAIL} --admin_password=${WP_ADMIN_PASS} --skip-email"
rsync -ave "ssh -p ${REMOTE_PORT}" .htaccess ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/.htaccess --delete
TIME_STOP

# Create subdirectories in wp-content
INFO "Add wp-content folders..."
TIME_START
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && mkdir -p wp-content/themes"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && mkdir -p wp-content/plugins"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && mkdir -p wp-content/uploads"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && mkdir -p wp-content/languages"
TIME_STOP

# Update composer dependencies
INFO "Updating composer dependencies..."
TIME_START
rsync -ave "ssh -p ${REMOTE_PORT}" composer.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/composer.json
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && composer install"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && cp -R vendor/lewebsimple/* wp-content/plugins"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && cp -R vendor/wpackagist-plugin/* wp-content/plugins"
TIME_STOP

# Update files
INFO "Updating files..."
TIME_START
rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/themes/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/themes/ --delete --exclude node_modules
rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/plugins/ --delete --exclude node_modules
rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/mu-plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/mu-plugins/ --delete
rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/uploads/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/uploads/ --delete
rsync -ave "ssh -p ${REMOTE_PORT}" wp-content/languages/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/languages/ --delete
TIME_STOP

# Synchronize and backup remote database
INFO "Synchronizing and backup remote databases..."
TIME_START
wp db export tmp.sql --allow-root --skip-plugins --skip-themes --add-drop-table
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; mkdir -p ${DB_DIR}"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp db export ${DB_DIR}/${DB_FILENAME} --allow-root --skip-plugins --skip-themes --add-drop-table"
scp -p ${REMOTE_PORT} tmp.sql ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp db import tmp.sql"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/tmp.sql" && rm -f tmp.sql
TIME_STOP

# Replace domain
INFO "Replacing domain ${LOCAL_DOMAIN} => ${REMOTE_DOMAIN}..."
TIME_START
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http://${LOCAL_DOMAIN}' 'https://${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'http:\/\/${LOCAL_DOMAIN}' 'https:\/\/${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace 'https%3A%2F%2F${LOCAL_DOMAIN}' 'https%3A%2F%2F${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH}; wp search-replace '${LOCAL_DOMAIN}' '${REMOTE_DOMAIN}' --all-tables --skip-plugins --skip-themes"
TIME_STOP


