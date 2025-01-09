#!/bin/bash

# First argument is the backup directory
BACKUP_DIR=$1
mkdir -p ${BACKUP_DIR}

# Get current timestamp for backup file name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/personal_${TIMESTAMP}.sql"

# Perform backup using mysqldump with recommended parameters
mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} \
  --databases personal \
  --replace \
  --single-transaction \
  --column-statistics=0 \
  --skip-lock-tables \
  --routines \
  --triggers \
  --events \
  --hex-blob \
  --set-gtid-purged=OFF \
  --add-drop-database \
  --add-drop-table > ${BACKUP_FILE}

# Compress the backup
gzip ${BACKUP_FILE}

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo -e "\033[1;32mBackup completed successfully: ${BACKUP_FILE}.gz\033[0m"
else
    echo -e "\033[1;31mBackup failed!\033[0m"
    exit 1
fi

# Retention policy:
# 1. Keep all backups from last 7 days
# 2. For older backups, keep only the last 7 Sunday backups

# First, handle files older than 7 days
find "${BACKUP_DIR}" -name "personal_*.sql.gz" -type f -mtime +7 | while read -r backup_file; do
    # Extract the date from filename (assumes format personal_YYYYMMDD_HHMMSS.sql.gz)
    filename=$(basename "$backup_file")
    date_part=$(echo "$filename" | grep -o '[0-9]\{8\}')
    
    # Convert to date format for day of week check (0 is Sunday)
    day_of_week=$(date -d "${date_part:0:4}-${date_part:4:2}-${date_part:6:2}" +%w)
    
    # If it's not a Sunday backup, delete it
    if [ "$day_of_week" != "0" ]; then
        echo "Removing non-Sunday backup: $backup_file"
        rm "$backup_file"
    fi
done

# Then, keep only the last 7 Sunday backups
sunday_backups=$(find "${BACKUP_DIR}" -name "personal_*.sql.gz" -type f -mtime +7 | while read -r backup_file; do
    filename=$(basename "$backup_file")
    date_part=$(echo "$filename" | grep -o '[0-9]\{8\}')
    day_of_week=$(date -d "${date_part:0:4}-${date_part:4:2}-${date_part:6:2}" +%w)
    if [ "$day_of_week" = "0" ]; then
        echo "$backup_file"
    fi
done | sort -r)

# Count Sunday backups and remove excess ones
count=0
echo "$sunday_backups" | while read -r backup_file; do
    count=$((count + 1))
    if [ $count -gt 7 ]; then
        echo "Removing old Sunday backup: $backup_file"
        rm "$backup_file"
    fi
done 