apt-get install -y docker 
docker run -d -p 9100:9100 --name=node_exporter prom/node-exporter
