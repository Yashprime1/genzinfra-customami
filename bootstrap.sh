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
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker exec %n stop
ExecStartPre=-/usr/bin/docker rm %n
ExecStartPre=/usr/bin/docker pull prom/node-exporter
ExecStart=/usr/bin/docker run --rm --name %n \
-v  /proc:/host/proc:ro \
-v /sys:/host/sys:ro \
 -v /:/rootfs:ro prom/node-exporter  \
-p 9100:9100 \
--stop-timeout 60 \
prom/node-exporter  --path.procfs=\"/host/proc\"  --path.rootfs=\"/rootfs\" --path.sysfs=\"/host/sys\" --path.udev.data=\"/rootfs/run/udev/data\"  --collector.filesystem.mount-points-exclude=\"^/(sys|proc|dev|host|etc)($$|/)\" 
ExecStop=/usr/bin/docker exec %n stop
[Install]
WantedBy=default.target"
echo "$CONTENT" >> /etc/systemd/system/docker.node_exporter.service
docker run  --name=node_exporter  prom/node-exporter
systemctl enable docker.node_exporter
systemctl start docker.node_exporter





