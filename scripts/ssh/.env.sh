#==========================
# GLOBAL CONFIG FILE
#==========================

# Local server
LOCAL_DOMAIN=''

# Remote server
REMOTE_DOMAIN=''
REMOTE_USER=''
REMOTE_PASS='' # Leave empty if you use SSH keys
REMOTE_HOST=''
REMOTE_PATH=''
REMOTE_PORT='22'

# Remote Wordpress config (optional)
WP_ADMIN_USER=''
WP_ADMIN_EMAIL=''
WP_ADMIN_PASS=''
WP_PREFIX='wp_'
DB_NAME=''
DB_USER=''
DB_PASS=''

# Backup config
REMOTE_BACKUP_SOURCE_PATH=''
REMOTE_BACKUP_DEST_PATH=''

#==========================

# Excluded files regex (local to remote for rsync command)
exclude_files='.*node_modules\/.*|.*\.git\/.*|.*composer\..*|.*package\..*|.*\.gitignore|.*webpack\.config\..*|.*yarn\..*|.*postcss\.config\..*|.*tailwind\.config\..*|tsconfig\.json|.*\.md'



