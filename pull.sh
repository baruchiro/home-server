#!/bin/bash

# echo -e "\033[1;34m🛑 Stopping home-server-compose.service...\033[0m"
# sudo systemctl stop home-server-compose.service

echo -e "\033[1;34m📥 Pulling latest code from git...\033[0m"
git pull

echo -e "\033[1;34m🐳 Pulling latest Docker images...\033[0m"
# Pull images for each stack
docker compose -f infra-stack.yml pull
docker compose -f media-stack.yml pull
docker compose -f homeassistant-stack.yml pull
docker compose -f paperless-stack.yml pull
docker compose -f budget-stack.yml pull
docker compose -f budibase-stack.yml pull

./deploy.sh

# echo -e "\033[1;34m🚀 Starting home-server-compose.service...\033[0m"
# sudo systemctl start home-server-compose.service

# echo -e "\033[1;34m📋 Tailing logs for home-server-compose.service...\033[0m"
# journalctl -u home-server-compose.service -f

# docker system prune -a --volumes
