#!/bin/bash

echo -e "\033[1;34m📦 Deploying Infrastructure Stack...\033[0m"
docker compose -p infra -f infra-stack.yml up -d

echo -e "\033[1;34m🎬 Deploying Media Stack...\033[0m"
docker compose -p media -f media-stack.yml up -d

echo -e "\033[1;34m🏠 Deploying Home Assistant Stack...\033[0m"
docker compose -p homeassistant -f homeassistant-stack.yml up -d

echo -e "\033[1;34m💰 Deploying Budget Stack...\033[0m"
docker compose -p budget -f budget-stack.yml up -d

echo -e "\033[1;34m📱 Deploying Budibase Stack...\033[0m"
docker compose -p budibase -f budibase-stack.yml up -d

# Paperless stack must be deployed last because it contains Ofelia service
# which needs to detect and manage all other containers for scheduled tasks
echo -e "\033[1;34m📄 Deploying Paperless Stack (with Ofelia)...\033[0m"
docker compose -p paperless -f paperless-stack.yml up -d
