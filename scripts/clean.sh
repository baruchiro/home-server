#!/bin/bash
cd $(dirname "$0")/..

docker-compose up -d

docker container prune -f
docker image prune -f
docker volume prune -f
