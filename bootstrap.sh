#!/bin/bash
set -euxo pipefail
sudo mkdir -p /etc/ecs  
sudo touch /etc/ecs/ecs.config
sudo mkdir -p /mongo/data
sudo mkdir -p /mongo/keys
sudo chmod -R +777 /etc/ecs
sudo chmod -R +777 /mongo/data
sudo chmod -R +400 /mongo/keys
sudo echo "ECS_CLUSTER=MongoEcsCluster" >> /etc/ecs/ecs.config
sudo openssl rand -base64 756 >  /mongo/keys/replicakey
sudo chmod 400 /mongo/keys/replicakey
sudo echo "ECS_AVAILABLE_LOGGING_DRIVERS='[\"awsfirelens\",\"json-file\"]'" >> /etc/ecs/ecs.config
curl -O https://s3.us-west-2.amazonaws.com/amazon-ecs-agent-us-west-2/amazon-ecs-init-latest.x86_64.rpm
sudo yum localinstall -y amazon-ecs-init-latest.x86_64.rpm
sudo yum install -y docker
sudo systemctl enable --now --no-block ecs