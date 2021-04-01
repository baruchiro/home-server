#!/bin/bash
sudo systemctl stop home-server-compose.service
git pull
# seed/init.sh
# docker-compose -f docker-compose.yml -f docker-compose.mongo.yml build --no-cache mongo-seed
# docker-compose -f docker-compose.yml -f docker-compose.mongo.yml build mongo-seed
# docker-compose -f docker-compose.yml -f docker-compose.mongo.yml pull
docker-compose -f docker-compose.yml pull
sudo systemctl start home-server-compose.service
docker image prune -f
journalctl -u home-server-compose.service -f
