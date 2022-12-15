# Work with Webpack

## Installation prerequist

intall nodejs: https://nodejs.org/en/download/  
install yarn: https://classic.yarnpkg.com/lang/en/docs/install/

## How to generate the assets bundle

In a terminal, position yourself at the same place of webpack.config.json
``` bash
cd /PATH/TO/WEBPACK_CONFIG_FILE/
```

Install all dependencies
``` bash
yarn install
```

Build for development (Watch change + source map for debugging in devtools)
``` bash
yarn dev
```

-or-

Build for production
``` bash
yarn build
```
---------------------------

# Work with Composer

Good to know:
All plugins at https://wordpress.org/plugins/ are also available as a composer repository at https://wpackagist.org/.

In a terminal, position yourself at the Wordpress root directory
```
cd /PATH/TO/WP/ROOT
```

```composer install``` (to install plugins without updating them)  
```composer update``` (to install the plugins but also to update them with the latest stable version)

----------------------------

# Work with automated scripts

These scripts allow you to update your files and database from the server to your local environment and vice versa.

## Installation prerequist

install wp-cli: https://make.wordpress.org/cli/handbook/guides/installing/

## How to use

In a terminal, position yourself at the Wordpress root directory
```
cd /PATH/TO/WP/ROOT
```

Run a script
```
./script/<script-name>.sh
```

Comment or uncomment the appropriate block of code inside the script file.