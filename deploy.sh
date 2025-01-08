#!/bin/bash

echo -e "\033[1;34m📦 Deploying Infrastructure Stack...\033[0m"
docker compose -p infra -f infra-stack.yml up -d

echo -e "\033[1;34m🎬 Deploying Media Stack...\033[0m"
docker compose -p media -f media-stack.yml up -d

echo -e "\033[1;34m🏠 Deploying Home Assistant Stack...\033[0m"
docker compose -p homeassistant -f homeassistant-stack.yml up -d

echo -e "\033[1;34m📊 Deploying NoCode Stack...\033[0m"
docker compose -p nocode -f nocode-stack.yml up -d

echo -e "\033[1;34m📄 Deploying Paperless Stack...\033[0m"
docker compose -p paperless -f paperless-stack.yml up -d

echo -e "\033[1;34m📱 Deploying Budibase Stack...\033[0m"
docker compose -p budibase -f budibase-stack.yml up -d
