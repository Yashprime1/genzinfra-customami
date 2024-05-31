apt-get install -y docker
aws s3 cp s3://system-sharedresources-ssms3bucket-ad5ymdxwx114/bamboo-elastic-agent/jq/jq-1.7.1.tar .
tar -xvf jq-1.7.1.tar
cd jq-1.7.1
apt install -y autoconf libtool build-essential
autoreconf -i
./configure
make
make install
ln -s /usr/local/bin/jq /usr/bin/jq 
CONTENT="[Unit]
Description=My Docker Container
Requires=docker.service
After=docker.service
[Service]
Restart=always
ExecStart=/usr/bin/docker start -a node-exporter
ExecStop=/usr/bin/docker stop -t 2 node-exporter
[Install]
WantedBy=multi-user.target
"
echo "$CONTENT" >> /etc/systemd/system/docker.node_exporter.service
docker run -d -p 9100:9100 --name=node_exporter -v  /proc:/host/proc:ro -v /sys:/host/sys:ro -v /:/rootfs:ro prom/node-exporter --path.procfs="/host/proc"  --path.rootfs="/rootfs" --path.sysfs="/host/sys" --path.udev.data="/rootfs/run/udev/data"  --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)" 
systemctl enable docker.node_exporter.service
systemctl start docker.node_exporter.service






