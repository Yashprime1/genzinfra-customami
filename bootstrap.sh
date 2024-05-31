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
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.3.1.linux-amd64*
sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<EOF\n[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=nobody\nExecStart=/usr/local/bin/node_exporter\n\n[Install]\nWantedBy=default.target\nEOF'
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter &





