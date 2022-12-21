##################################################
# SYNOPSYS
##################################################
# initwww <project_name> --new
# initwww <project_name> --clone <git_url>
##################################################

set -e

ASW_RES_FOLDER=/home/${USER}/Scripts/ASW_RESSOURCE
PROJECT_NAME=$1
ROOT_SERVER=/opt/lampp/htdocs
WORKSPACE_ROOT_DIR=$PWD/${PROJECT_NAME}
WORDPRESS_ROOT_DIR=$PWD/${PROJECT_NAME}/${PROJECT_NAME}
VHOSTS_PATH=/opt/lampp/etc/extra/httpd-vhosts.conf
HOSTS_PATH=/etc/hosts

# Validate arguments
if [[ "${PROJECT_NAME}" == "" || ( "$2" != "--new" && "$2" != "--clone" ) || ( "$2" == "--clone" && "$3" == "" ) ]]; then {
    printf "Error: Invalid command... \n"
    exit
}
fi

# Validate git remote repository
if [[ "$2" == "--clone" ]]; then {
    printf "Validate git remote repository ${3}... \n";
    mkdir -p ~/Tmp/gitclone && cd ~/Tmp/gitclone
    if git clone --quiet $3; then {
        printf "Found git remote repository. \n"
        rm -rf ~/Tmp/gitclone
    }
    else { 
        rm -rf ~/Tmp/gitclone && exit
    }
    fi
}
fi

# Init project
echo "Init project..."
mkdir -p $ROOT_SERVER/$PROJECT_NAME/$PROJECT_NAME
cd $WORKSPACE_ROOT_DIR 

# New project
if [[ "$2" == "--new" ]]; then {   
    echo "Create new project..."

    # Copy ./scripts, composer.json, .gitignore
    cp -R ${ASW_RES_FOLDER}/scripts/ ./${PROJECT_NAME}/.
    cp ${ASW_RES_FOLDER}/local/composer.json ./${PROJECT_NAME}/.
    cp ${ASW_RES_FOLDER}/local/.gitignore.sample ./${PROJECT_NAME}/.gitignore

    # Remove files from copy stuff
    rm -rf ./${PROJECT_NAME}/scripts/init.sh
    rm -rf ./${PROJECT_NAME}/scripts/.vscode

    # Replace placeholder <project_name> with ${PROJECT_NAME}
    sed -i "s/<project_name>/${PROJECT_NAME}/g" ./${PROJECT_NAME}/composer.json
}
fi

# Change directory to Wordpress root directory
cd $WORDPRESS_ROOT_DIR

# Git clone a remote project
if [[ "$2" == "--clone" ]]; then {
    echo "Clone project from ${3}..."
    git clone ${3} .
}
fi

echo "Create utils directories..."
mkdir -p $WORKSPACE_ROOT_DIR/_LOG
mkdir -p $WORKSPACE_ROOT_DIR/_TMP
mkdir -p $WORKSPACE_ROOT_DIR/.vscode

echo "Copy utils files in $WORKSPACE_ROOT_DIR..."
cp ${ASW_RES_FOLDER}/local/readme.md.sample ./readme.md
cp ${ASW_RES_FOLDER}/local/.htaccess .
cp ${ASW_RES_FOLDER}/local/placeholder.png .
cp ${ASW_RES_FOLDER}/local/launch.json ../.vscode/launch.json

echo "Replace placeholder in files..."
sed -i "s/<project_name>/${PROJECT_NAME}/g" ../.vscode/launch.json 

echo "Add vhost config..."
if [[ $( grep $PROJECT_NAME.localhost $VHOSTS_PATH ) == "" ]]; then
    cat ${ASW_RES_FOLDER}/local/vhost.conf | sed -e "s/<project_name>/${PROJECT_NAME}/g" | xargs -0  printf '\n%s\n' >> $VHOSTS_PATH
fi
if [[ $( grep $PROJECT_NAME.localhost $HOSTS_PATH ) == "" ]]; then
    echo "127.0.0.1	<project_name>.localhost" | sed -e "s/<project_name>/${PROJECT_NAME}/g" | xargs -0  printf '\n%s\n' >> $HOSTS_PATH
fi

echo "Install wordpress environment..."
DB_NAME=wp_${PROJECT_NAME}
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}";
wp core download --force --skip-content
wp core config --dbname=${DB_NAME}
wp core install --url=${PROJECT_NAME}.localhost --title=${PROJECT_NAME}
wp config set WP_DEBUG true --raw
wp config set WP_DEBUG_DISPLAY false --raw
wp config set SCRIPT_DEBUG true --raw
wp config set WP_DEBUG_LOG $WORKSPACE_ROOT_DIR/_LOG/wp-error.log

echo "Create required wordpress wp-content sub directories..."
mkdir -p $WORDPRESS_ROOT_DIR/wp-content/plugins
mkdir -p $WORDPRESS_ROOT_DIR/wp-content/themes
mkdir -p $WORDPRESS_ROOT_DIR/wp-content/uploads

echo "Install composer dependencies..."
if [[ -f "$WORDPRESS_ROOT_DIR/composer.json" ]]; then {
    composer update
}
fi

echo "Restart server..."
sudo /opt/lampp/lampp restart

echo "Open vscode..."
code $WORKSPACE_ROOT_DIR

echo "Site ready at http://${PROJECT_NAME}.$LOCAL_TLD"
