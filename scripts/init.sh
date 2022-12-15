set -e

ASW_RES_FOLDER=/home/${USER}/Scripts/ASW_RESSOURCE

# Validate arguments
if [[ "$1" == "" || ( "$2" != "--new" && "$2" != "--clone" ) || ( "$2" == "--clone" && "$3" == "" ) ]]; then {
    printf "Error: Invalid command... \n"
    printf "Valid commands are: \n"
    printf "initwww project_name --clone ssh_repo_path || --new \n"
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
cd /opt/lampp/htdocs
mkdir -p $1 && cd $1

# New project
if [[ "$2" == "--new" ]]; then {   
    echo "Create new project..."

    # Add directory project
    mkdir -p $1

    # Add ./scripts, composer.json, .gitignore
    cp -R ${ASW_RES_FOLDER}/starter/scripts/ ./$1/.
    cp ${ASW_RES_FOLDER}/starter/local/composer.json ./$1/.
    cp ${ASW_RES_FOLDER}/starter/local/.gitignore-sample ./$1/.gitignore

    # Replace placeholder <project_name> with $1
    sed -i "s/<project_name>/$1/g" ./$1/composer.json
}
fi

# Git clone a remote project
if [[ "$2" == "--clone" ]]; then {
    echo "Clone project from ${3}..."
    git clone ${3}
}
fi

# Change directory to web root
cd $1

# Install wordpress
echo "Install wordpress environment..."
DB_NAME=wp_$1
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}";
wp core download --force --skip-content
wp core config --dbname=${DB_NAME}
wp core install --url=$1.localhost --title=$1
wp config set WP_DEBUG true --raw
wp config set WP_DEBUG_DISPLAY false --raw
wp config set SCRIPT_DEBUG true --raw
echo "Create wordpress directories..."
mkdir -p ${PWD}/wp-content/plugins
mkdir -p ${PWD}/wp-content/themes
mkdir -p ${PWD}/wp-content/uploads

echo "Create utils directories..."
mkdir -p ${PWD}/../_LOG
mkdir -p ${PWD}/../_TMP
mkdir -p ${PWD}/../.vscode

echo "Copy utils files in ${PWD}..."
cp ${ASW_RES_FOLDER}/starter/local/readme.md .
cp ${ASW_RES_FOLDER}/starter/local/.htaccess .
cp ${ASW_RES_FOLDER}/starter/local/placeholder.png .
cp ${ASW_RES_FOLDER}/starter/local/launch.json ../.vscode/launch.json

echo "Replace placeholder in files..."
sed -i "s/<project_name>/$1/g" ../.vscode/launch.json 

echo "Add vhost-host conf..."
VHOSTS_PATH=/opt/lampp/etc/extra/httpd-vhosts.conf
HOSTS_PATH=/etc/hosts
if [[ $( grep ${1}.localhost $VHOSTS_PATH ) == "" ]]; then
    cat ${ASW_RES_FOLDER}/starter/local/vhost.conf | sed -e "s/<project_name>/$1/g" | xargs -0  printf '\n%s\n' >> $VHOSTS_PATH
fi
if [[ $( grep ${1}.localhost $HOSTS_PATH ) == "" ]]; then
    cat ${ASW_RES_FOLDER}/starter/local/host.conf | sed -e "s/<project_name>/$1/g" | xargs -0  printf '\n%s\n' >> $HOSTS_PATH
fi

echo "Install composer dependencies..."
if [[ -f "$PWD/composer.json" ]]; then {
    composer update
}
fi

echo "Restart server..."
sudo /opt/lampp/lampp restart

echo "Open vscode..."
code /opt/lampp/htdocs/$1

echo "Site ready at http://$1.$LOCAL_TLD"
