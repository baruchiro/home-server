#!/bin/bash
sudo systemctl restart home-server-compose.service
journalctl -u home-server-compose.service -f
