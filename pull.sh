#!/bin/bash
sudo systemctl stop home-server-compose.service
git pull
docker-compose pull
sudo systemctl start home-server-compose.service
docker image prune -f
journalctl -u home-server-compose.service -f
