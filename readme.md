# Automated scripts

These scripts allow you to update WordPress files and database from the server to your local environment 
and vice versa with the help of wp-cli and rsync under the hood.

It can also set you up, in no time, with a blank Wordpress project, the vhost, etc.
Take a look at ./scripts/wp-init.sh and adapt it to your development environment setup.

# If you wanna work with ./scripts/wp-init.sh
Create the wp-cli config file (config.yaml) to your home directory and fill it up.
@see https://make.wordpress.org/cli/handbook/references/config/
```
cp ./local/config.yaml.sample ~/.wp-cli/config.yaml
```

## Installation prerequist (SSH)

install wp-cli: https://make.wordpress.org/cli/handbook/guides/installing/
if not installed: install rsync CLI program

## Installation prerequist (S-FTP)
if not installed: install lftp CLI program

## Initial config set up

Fill up the congif file in .env.sh

Fill up the ~/.wp-cli/config.yaml with the appropriate info.  
@see https://make.wordpress.org/cli/handbook/references/config/

## Update from remote to local and vice versa

Copy the ./scripts folder to your Wordpress Project
```
cp -R ./scripts /PATH/TO/YOUR/WP/ROOT/PROJECT/*
```

In a terminal, position yourself at your Wordpress root project directory
```
cd /PATH/TO/YOUR/WP/ROOT/PROJECT
```

Run the script
```
./scripts/[ftp-ssh]/*.sh
```