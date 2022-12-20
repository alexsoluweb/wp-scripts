#==========================
# CONFIG FILE
#==========================

# Local server
# LOCAL_DOMAIN=

# Remote server
REMOTE_DOMAIN=giduwgduwguf.com
REMOTE_USER=
REMOTE_HOST=
REMOTE_PATH=
REMOTE_PORT=22

# Database backup directory
DB_DIR=_db_backups

# Remote Wordpress dev
WP_ADMIN_USER=''
WP_ADMIN_EMAIL=''
WP_ADMIN_PASS=''
DB_NAME=''
DB_USER=''
DB_PASS=''

#=============================
# END CONFIG
#=============================

# Escape special caracters
DB_PASS=`printf '%q' $DB_PASS`

# Determine local domain if not defined
if [[ -z "${LOCAL_DOMAIN}" ]]; then
{
  LOCAL_DOMAIN=${REMOTE_DOMAIN#www.}
  LOCAL_DOMAIN="${LOCAL_DOMAIN%%.*}.${LOCAL_TLD-localhost}"
}
fi
