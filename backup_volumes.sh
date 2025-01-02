#!/bin/bash

BACKUP_DIR=~/volume_backups/$(date +%Y%m%d)

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Get all volumes starting with home-server_
volumes=$(docker volume ls --format '{{.Name}}' | grep '^home-server_')

# Backup each volume using a temporary container
for volume in $volumes; do
    echo "Backing up $volume..."
    docker run --rm \
        -v $volume:/source:ro \
        -v $BACKUP_DIR:/backup \
        ubuntu \
        tar czf /backup/${volume}.tar.gz -C /source .
    echo "Finished backing up $volume"
done

echo "All backups completed in $BACKUP_DIR"