sudo systemctl stop home-server-compose.service
git pull
sudo systemctl start home-server-compose.service
journalctl -u home-server-compose.service -f
