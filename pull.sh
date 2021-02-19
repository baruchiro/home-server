#!/bin/bash
sudo systemctl stop home-server-compose.service
seed/init.sh
git pull
docker-compose pull
sudo systemctl start home-server-compose.service
docker image prune -f
docker volume prune -f
journalctl -u home-server-compose.service -f
