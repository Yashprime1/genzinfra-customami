function create_user_bamboo(){
    if ! id -u bamboo &> /dev/null
    then
        log_info "User bamboo not found. Will create"
        useradd --create-home --home /home/bamboo --uid 1000 --user-group --shell /bin/bash bamboo
    fi
}

function setup_bamboo_home_dir(){
    while [[ ! -b $(readlink -f /dev/sdp) ]]
    do
        echo 'waiting for /dev/sdp'
        sleep 2
    done

    if ! file -s $(readlink -f /dev/sdp) | grep 'ext4'
    then
        log_info "/dev/sdp nvme is not formatted. Will format and label"
        mkfs.ext4 $(readlink -f /dev/sdp)
        e2label $(readlink -f /dev/sdp) bamboo-home
    fi

    if ! [[ -d /home/bamboo ]]
    then
        log_info "/home/bamboo does not exists. Will create"
        mkdir /home/bamboo
        chown bamboo:bamboo /home/bamboo
    fi

    if ! mount | grep /home/bamboo
    then
        log_info "/dev/sdp is not mounted on /home/bamboo will mount"
        mount $(readlink -f /dev/sdp)  /home/bamboo
        chown bamboo:bamboo /home/bamboo
    fi

    if ! cat /etc/fstab | grep 'bamboo-home'
    then
        log_info "LABEL=bamboo-home is not in /etc/fstab. Will add entry"
        echo "LABEL=bamboo-home /home/bamboo ext4 defaults,nofail 0 2" >> /etc/fstab
    fi
}

function setup_bamboo_data_dir(){
    while [[ ! -b $(readlink -f /dev/sdf) ]]
    do
        echo 'waiting for /dev/sdf'
        sleep 2
    done

    if ! file -s $(readlink -f /dev/sdf) | grep 'ext4'
    then
        log_info "/dev/sdf nvme is not formatted. Will format and label"
        mkfs.ext4 $(readlink -f /dev/sdf)
        e2label $(readlink -f /dev/sdf) bamboo-data
    fi

    if ! [[ -d /var/atlassian/application-data/bamboo ]]
    then
        log_info "/var/lib/bamboo does not exists. Will create"
        mkdir -p /var/atlassian/application-data/bamboo
        chown bamboo:bamboo /var/atlassian/application-data/bamboo
    fi

    if ! mount | grep /var/atlassian/application-data/bamboo
    then
        log_info "/dev/sdf is not mounted on /var/atlassian/application-data/bamboo Will mount"
        mount $(readlink -f /dev/sdf)  /var/atlassian/application-data/bamboo
        chown bamboo:bamboo /var/atlassian/application-data/bamboo
    fi

    if ! cat /etc/fstab | grep 'bamboo-data'
    then
        log_info "LABEL=bamboo-data is not in /etc/fstab. Will add entry"
        echo "LABEL=bamboo-data /var/atlassian/application-data/bamboo ext4 defaults,nofail 0 2" >> /etc/fstab
    fi
}


sudo echo "Eu-Bamboo" > /etc/cfn_stackname
if ! id -u bamboo &> /dev/null
then
    log_info "User bamboo not found. Will be created"
    sudo useradd --create-home --home /home/bamboo --uid 1000 --user-group --shell /bin/bash bamboo
fi

setup_bamboo_home_dir
setup_bamboo_data_dir

sudo mkdir -p /etc/ecs  
sudo touch /etc/ecs/ecs.config
sudo chmod -R +777 /etc/ecs
sudo echo "ECS_CLUSTER=BambooEcsCluster" >> /etc/ecs/ecs.config
sudo echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m" >> /etc/ecs/ecs.config
sudo echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"splunk\",\"awslogs\"]" >> /etc/ecs/ecs.config

log_info "Bamboo bootstrap complete."

curl -O https://s3.us-west-2.amazonaws.com/amazon-ecs-agent-us-west-2/amazon-ecs-init-latest.x86_64.rpm
sudo yum localinstall -y amazon-ecs-init-latest.x86_64.rpm
sudo yum install -y docker
sudo systemctl enable --now --no-block ecs
