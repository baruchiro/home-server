#!/bin/bash

echo -e "\033[1;34mInitializing Docker Swarm...\033[0m"
docker swarm init || echo "Node is already a swarm manager"

echo -e "\033[1;34mDeploying infra-stack...\033[0m"
docker stack deploy -c infra-stack.yml infra-stack

echo -e "\033[1;34mDeploying media-stack...\033[0m"
docker stack deploy -c media-stack.yml media-stack

echo -e "\033[1;34mDeploying homeassistant-stack...\033[0m"
docker stack deploy -c homeassistant-stack.yml homeassistant-stack

echo -e "\033[1;34mDeploying nocodb-stack...\033[0m"
docker stack deploy -c nocodb-stack.yml nocodb-stack

echo -e "\033[1;34mDeploying paperless-stack...\033[0m"
docker stack deploy -c paperless-stack.yml paperless-stack
