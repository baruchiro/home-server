#!/bin/bash

echo -e "\033[1;34m📄 Stopping Paperless Stack...\033[0m"
docker compose -p paperless -f paperless-stack.yml down

echo -e "\033[1;34m💰 Stopping Budget Stack...\033[0m"
docker compose -p budget -f budget-stack.yml down

echo -e "\033[1;34m🏠 Stopping Home Assistant Stack...\033[0m"
docker compose -p homeassistant -f homeassistant-stack.yml down

echo -e "\033[1;34m🎬 Stopping Media Stack...\033[0m"
docker compose -p media -f media-stack.yml down

echo -e "\033[1;34m📦 Stopping Infrastructure Stack...\033[0m"
docker compose -p infra -f infra-stack.yml down

echo -e "\033[1;34m📱 Stopping Budibase Stack...\033[0m"
docker compose -p budibase -f budibase-stack.yml down 