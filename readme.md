# Automated scripts

These scripts allow you to update WordPress files and database from the server to your local environment 
and vice versa with the help of wp-cli and rsync under the hood.

It can also set you up, with no time, a blank Wordpress project, the vhost, etc. or from a git remote repository.
Take a look at ./scripts/init.sh and adapt it to your development environment.

## Installation prerequist

install wp-cli: https://make.wordpress.org/cli/handbook/guides/installing/

## Initial config set up

Fill up the remote congif file in ./scripts/.env.sh

If you wanna work with ./scripts/init.sh:

Copy the wp core config file (config.yaml)
```
cp ./local/config.yaml.sample ~/.wp-cli/config.yaml
```

Fill up the ~/.wp-cli/config.yaml with the appropriate info.
@see https://make.wordpress.org/cli/handbook/references/config/

## Update from remote to local and vice versa

Copy the ./scripts folder to your Wordpress Project
```
cp -R ./scripts /PATH/TO/YOUR/WP/ROOT/PROJECT*
```

In a terminal, position yourself at the Wordpress root directory
```
cd /PATH/TO/YOUR/WP/ROOT/PROJECT
```

Run a script that suit your need
```
./scripts/update-<local-dev-prod>.sh
```

Comment or uncomment the appropriate block of code inside the update-<local-dev-prod>.sh file.