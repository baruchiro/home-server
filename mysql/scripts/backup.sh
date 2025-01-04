#!/bin/bash
BACKUP_DIR=$1
mkdir -p ${BACKUP_DIR}

# Get current timestamp for backup file name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/nocobase_${TIMESTAMP}.sql"

# Perform backup using mysqldump with recommended parameters
mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} \
  --databases nocobase \
  --replace \
  --single-transaction \
  --column-statistics=0 \
  --skip-lock-tables \
  --routines \
  --triggers > ${BACKUP_FILE}

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo -e "\033[1;32mBackup completed successfully: ${BACKUP_FILE}\033[0m"
else
    echo -e "\033[1;31mBackup failed!\033[0m"
    exit 1
fi
