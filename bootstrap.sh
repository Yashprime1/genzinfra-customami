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
docker run -d -p 9100:9100 --name=node_exporter prom/node-exporter
