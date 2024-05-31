wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
cd node_exporter-1.8.1.linux-amd64
./node_exporter --web.listen-address=":8090" > node_exporter.log 2>&1 &
NODE_EXPORTER_PID=$!
echo "Node exporter started in the background with PID $NODE_EXPORTER_PID"
echo "Bootstrapped elastic instance"
