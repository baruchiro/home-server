# https://forum.rclone.org/t/docker-plugin-fail-to-start-reinstall/29871/8

docker plugin disable rclone
sudo rm /var/lib/docker-plugins/rclone/cache/docker-plugin.state
docker plugin enable rclone
ps -efa | grep "rclone serve docker" | grep -v "grep"
