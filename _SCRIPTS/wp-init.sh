#!/bin/bash
set -e

#=================================================
# SYNOPSYS
#=================================================
# This script is used to init a new Wordpress project.
#
# usage:
# ./wp-init.sh <project_name> --new
# ./wp-init.sh <project_name> --clone <git_url>
#=================================================

#=================================================
# CONFIG
#=================================================
ASW_RES_FOLDER="/home/$USER/Scripts/ASW_RESSOURCE"
PROJECT_NAME="$1"
ROOT_SERVER='/opt/lampp/htdocs'
WORKSPACE_ROOT_DIR="$ROOT_SERVER/$PROJECT_NAME"
WORDPRESS_ROOT_DIR="$ROOT_SERVER/$PROJECT_NAME/$PROJECT_NAME"
VHOSTS_PATH='/opt/lampp/etc/extra/httpd-vhosts.conf'
HOSTS_PATH='/etc/hosts'
DB_NAME="$(echo wp_$PROJECT_NAME | sed 's/-/_/g')"
LOCAL_TLD='localhost'
#=================================================
# VALIDATION
#=================================================

# Validate arguments
if [[ "$PROJECT_NAME" == "" || ( "$2" != "--new" && "$2" != "--clone" ) || ( "$2" == "--clone" && "$3" == "" ) ]]; then 
    printf "Error: Invalid command... \n"
    exit

fi

# Validate git remote repository
if [[ "$2" == "--clone" ]]; then 
    printf "Validate git remote repository $3... \n";
    mkdir -p ~/Tmp/gitclone && cd ~/Tmp/gitclone
    if git clone --quiet $3; then 
        printf "Found git remote repository. \n"
        rm -rf ~/Tmp/gitclone
    else  
        rm -rf ~/Tmp/gitclone && exit
    fi
fi

# Init project
echo "Init project..."
mkdir -p $ROOT_SERVER/$PROJECT_NAME/$PROJECT_NAME
cd $WORKSPACE_ROOT_DIR 

# Create Wordpress project
if [[ "$2" == "--new" ]]; then    
    echo "Create new Wordpress project..."

    # Copy utils files
    cp -R $ASW_RES_FOLDER/_SCRIPTS $WORKSPACE_ROOT_DIR/_SCRIPTS
    cp $ASW_RES_FOLDER/local/composer.json $WORDPRESS_ROOT_DIR/composer.json
    cp $ASW_RES_FOLDER/local/.gitignore.sample $WORDPRESS_ROOT_DIR/.gitignore

    # Remove unnecessary utils files
    rm -rf $WORKSPACE_ROOT_DIR/_SCRIPTS/wp-init.sh
    rm -rf $WORKSPACE_ROOT_DIR/_SCRIPTS/.vscode

    # Replace placeholder <project_name> with $PROJECT_NAME
    sed -i "s/<project_name>/$PROJECT_NAME/g" $WORDPRESS_ROOT_DIR/composer.json

    # Change directory to Wordpress root directory
    cd $WORDPRESS_ROOT_DIR

    # Install Wordpress
    mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME";
    wp core download --force --skip-content
    wp core config --dbname="$DB_NAME"
    wp core install --url="$PROJECT_NAME.$LOCAL_TLD" --title="$PROJECT_NAME"

    # Set Wordpress debug config
    wp config set WP_DEBUG 'true' --raw
    wp config set WP_DEBUG_DISPLAY 'false' --raw
    wp config set SCRIPT_DEBUG 'true' --raw
    wp config set WP_DEBUG_LOG $WORKSPACE_ROOT_DIR/_LOG/wp-error.log

    # Add Wordpress wp-content directories
    mkdir -p $WORDPRESS_ROOT_DIR/wp-content/plugins && chmod 775 $WORDPRESS_ROOT_DIR/wp-content/plugins
    mkdir -p $WORDPRESS_ROOT_DIR/wp-content/themes && chmod 775 $WORDPRESS_ROOT_DIR/wp-content/themes
    mkdir -p $WORDPRESS_ROOT_DIR/wp-content/uploads && chmod 775 $WORDPRESS_ROOT_DIR/wp-content/uploads

    # Install plugins
    echo "Install composer plugins..."
    if [[ -f "$WORDPRESS_ROOT_DIR/composer.json" ]]; then 
        composer update
    fi
fi

# Git clone a remote project
if [[ "$2" == "--clone" ]]; then 
    echo "Clone project from $3..."
    git clone $3 .
fi

echo "Create utils directories..."
mkdir -p $WORKSPACE_ROOT_DIR/_LOG
mkdir -p $WORKSPACE_ROOT_DIR/_TMP
mkdir -p $WORKSPACE_ROOT_DIR/_BACKUPS
mkdir -p $WORKSPACE_ROOT_DIR/.vscode

echo "Copy utils files in $WORKSPACE_ROOT_DIR..."
# cp $ASW_RES_FOLDER/local/readme.md.sample ./readme.md
cp $ASW_RES_FOLDER/local/.htaccess $WORDPRESS_ROOT_DIR/.htaccess
cp $ASW_RES_FOLDER/local/placeholder.png $WORDPRESS_ROOT_DIR/placeholder.png
cp $ASW_RES_FOLDER/local/launch.json $WORKSPACE_ROOT_DIR/.vscode/launch.json
cp -R $ASW_RES_FOLDER/local/_DOC $WORKSPACE_ROOT_DIR/_DOC/

echo "Replace placeholder in files..."
sed -i "s/<project_name>/$PROJECT_NAME/g" $WORKSPACE_ROOT_DIR/.vscode/launch.json 

echo "Add vhost config..."
if [[ $( grep $PROJECT_NAME.$LOCAL_TLD $VHOSTS_PATH ) == "" ]]; then
    cat $ASW_RES_FOLDER/local/vhost.conf | sed -e "s/<project_name>/$PROJECT_NAME/g" | xargs -0  printf '\n%s\n' >> $VHOSTS_PATH
fi

echo "Add hosts config..."
if [[ $( grep $PROJECT_NAME.$LOCAL_TLD $HOSTS_PATH ) == "" ]]; then
    echo "127.0.0.1	$PROJECT_NAME.$LOCAL_TLD" | xargs -0  printf '\n%s\n' >> $HOSTS_PATH
fi

echo "Restart server..."
sudo /opt/lampp/lampp restart

echo "Open vscode..."
code $WORKSPACE_ROOT_DIR

echo "Site ready at http://$PROJECT_NAME.$LOCAL_TLD"
