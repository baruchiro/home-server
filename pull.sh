#!/bin/bash
sudo systemctl stop home-server-compose.service
git pull
seed/init.sh
docker-compose build --no-cache mongo-seed
docker-compose pull
sudo systemctl start home-server-compose.service
journalctl -u home-server-compose.service -f
