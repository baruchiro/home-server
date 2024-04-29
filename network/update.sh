cp .env *.env network/
cd network
sudo systemctl stop network-home-server.service
docker-compose pull
sudo systemctl start network-home-server.service
journalctl -u network-home-server.service -f
