instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
security_group_id=$(curl -s http://169.254.169.254/latest/meta-data/security-groups | cut -d ' ' -f 1)
key_pair_name=$(curl -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key | cut -d ' ' -f 3)

aws ec2 create-tags --resources $instance_id --region eu-west-1 --tags \
  '[{"Key":"packer-name","Value":"elastic-agent-ami-builder"}, \
    {"Key":"instance-id","Value":"'$instance_id'"}, \
    {"Key":"security-group","Value":"'$security_group_id'"}, \
    {"Key":"key-pair","Value":"'$key_pair_name'"}]'

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
sleep 300
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.8.1.linux-amd64*
bash -c 'cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:8090
[Install]
WantedBy=multi-user.target
EOF'
sudo systemctl daemon-reload
sudo systemctl unmask node_exporter
sudo systemctl enable node_exporter
sudo systemctl start node_exporter &





