#!/bin/bash
echo -e "\033[1;34mStopping home-server-compose.service...\033[0m"
sudo systemctl stop home-server-compose.service

echo -e "\033[1;34mPulling latest code from git...\033[0m"
git pull

echo -e "\033[1;34mPulling latest Docker images...\033[0m"
docker-compose pull

echo -e "\033[1;34mStarting home-server-compose.service...\033[0m"
sudo systemctl start home-server-compose.service

echo -e "\033[1;34mTailing logs for home-server-compose.service...\033[0m"
journalctl -u home-server-compose.service -f

# docker system prune -a --volumes
