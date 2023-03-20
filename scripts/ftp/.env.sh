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
user=''
pass=''
host=''
# FTP default port 21, SFTP default port 22
port='21' 

# (S)FTP local directory to mirror (absolute path)
local_dirs=''

# (S)FTP remote directory to mirror (absolute path from ftp root folder)
remote_dirs=''

# Project path for yarn --cwd build command (absolute path)
project_path=''


#=================================================

# Excluded files regex (local to remote for lftp mirror command)
exclude_files='.*node_modules\/.*|.*\.git\/.*|.*composer\..*|.*package\..*|.*\.gitignore|.*webpack\.config\..*|.*yarn\..*|.*postcss\.config\..*|.*tailwind\.config\..*|tsconfig\.json|.*\.md'

# Dry run output file
dry_run_output_file="$PWD/../_LOG/ftp-dry-run.log"

