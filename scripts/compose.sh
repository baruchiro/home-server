#!/bin/bash
cd $(dirname "$0")/..

docker-compose -f docker-compose.yml -f docker-compose.mongo.yml $1 $2
