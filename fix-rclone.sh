#!/bin/bash

# https://forum.rclone.org/t/docker-plugin-fail-to-start-reinstall/29871/8

echo -e "\033[1;34mWARNING: This will undeploy all stacks and reset rclone plugin.\033[0m"
read -p "Are you sure you want to proceed? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo -e "\033[1;34mUndeploying all stacks...\033[0m"
./undeploy.sh

echo -e "\033[1;34mRemoving docker volumes...\033[0m"
docker volume rm paperless_paperless-export
docker volume rm paperless_paperless-consume
docker volume rm infra_mysql-backup

docker plugin disable rclone
sudo rm /var/lib/docker-plugins/rclone/cache/docker-plugin.state
docker plugin enable rclone
ps -efa | grep "rclone serve docker" | grep -v "grep"
