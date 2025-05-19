cp .env *.env network/
cd network
docker-compose pull
sudo systemctl restart network-home-server.service
journalctl -u network-home-server.service -f
