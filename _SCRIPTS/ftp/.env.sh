#=================================================
# CONFIG
#=================================================
# Local server domain
LOCAL_DOMAIN=''
# Remote server domain
REMOTE_DOMAIN=''
# Exported remote database local path (absolute path)
DB_PATH=''
# (S)FTP login credentials
USER=''
PASS=''
HOST=''
# FTP default port 21, SFTP default port 22
PORT='21' 
# (S)FTP local directory to mirror (absolute path)
LOCAL_DIRS=''
# (S)FTP remote directory to mirror (absolute path from ftp root folder)
REMOTE_DIRS=''
# Project path for yarn --cwd build command (absolute path)
BUILD_PATH=''
#=================================================

# Excluded files regex (local to remote for lftp mirror command)
EXCLUDE_FILES='.*node_modules\/.*|.*\.git\/.*|.*composer\..*|.*package\..*|.*\.gitignore|.*webpack\.config\..*|.*yarn\..*|.*postcss\.config\..*|.*tailwind\.config\..*|tsconfig\.json|.*\.md'
# Dry run output file
DRY_RUN_LOG_PATH="$PWD/../_LOG/ftp-dry-run.log"

