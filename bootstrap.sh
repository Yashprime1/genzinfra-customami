echo "Installing build dependencies"

export JAVA_VERSION_MAJOR=8
export JAVA_VERSION_MINOR=332
export JAVA_VERSION_BUILD=08.1

sudo apt-get -o DPkg::Lock::Timeout=300 update -y &

sudo apt-get -o DPkg::Lock::Timeout=300 remove vim -y &

sudo apt-get -o DPkg::Lock::Timeout=300 install -y curl git openssl wget unzip ffmpeg &


sudo apt-get -o DPkg::Lock::Timeout=300 install -y jq &


sudo apt-get -o DPkg::Lock::Timeout=300 install -y python3-pip python3-dev python3-setuptools
sudo apt-get -o DPkg::Lock::Timeout=300 install -y python3-pip --fix-missing

# Changed by Jude & Valeri since libssl1.0.0 and multiarch-support is unavailable
#apt-get install --only-upgrade snapd libssl1.0.0 policykit-1 libc-dev-bin libc-bin libc6 libc6-dev locales multiarch-support -y
sudo apt-get -o DPkg::Lock::Timeout=300 install --only-upgrade snapd policykit-1 libc-dev-bin libc-bin libc6 libc6-dev locales -y

#packages need with some libraries to allow running browsers in headless mode
sudo apt-get -o DPkg::Lock::Timeout=300 install -y libgbm-dev libxcomposite-dev libxrandr-dev libxkbcommon-dev libpangocairo-1.0-0 libatk1.0-0 libatk-bridge2.0-0
####
pip3 install awscli --upgrade --user

wget https://corretto.aws/downloads/resources/${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}.${JAVA_VERSION_BUILD}/amazon-corretto-${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}.${JAVA_VERSION_BUILD}-linux-x64.tar.gz >> /dev/null  \
    && sudo tar -xzf amazon-corretto-${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}.${JAVA_VERSION_BUILD}-linux-x64.tar.gz -C /opt \
    && sudo rm -rf amazon-corretto-${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}.${JAVA_VERSION_BUILD}-linux-x64.tar.gz

# 11 is for Bamboo Agent
cd /tmp  \
    && wget https://corretto.aws/downloads/resources/11.0.19.7.1/amazon-corretto-11.0.19.7.1-linux-x64.tar.gz >> /dev/null  \
    &&  sudo tar -xzf amazon-corretto-11.0.19.7.1-linux-x64.tar.gz -C /opt \
    && sudo rm -rf amazon-corretto-11.0.19.7.1-linux-x64.tar.gz


# JDK 17 added by Jude.
curl --silent https://corretto.aws/downloads/resources/17.0.1.12.1/amazon-corretto-17.0.1.12.1-linux-x64.tar.gz | sudo tar -C /opt -xzf - && mv /opt/amazon-corretto-17.0.1.12.1-linux-x64 /opt/amazon-corretto-17-linux-x64
# JDK 18 added by Yashdeep
curl --silent https://corretto.aws/downloads/resources/18.0.2.9.1/amazon-corretto-18.0.2.9.1-linux-x64.tar.gz | sudo tar -C /opt -xzf - && mv /opt/amazon-corretto-18.0.2.9.1-linux-x64 /opt/amazon-corretto-18-linux-x64
#installing google chrome headless for test cafe
curl -s "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -o google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb


curl -s https://archive.apache.org/dist/ant/binaries/apache-ant-1.9.3-bin.tar.gz | sudo  tar -v -xz -C /opt/

# Download and install jq
# aws s3 cp s3://system-sharedresources-ssms3bucket-ad5ymdxwx113/bamboo-elastic-agent/jq/jq-1.7.1.tar.gz .
# tar -xvf jq-1.7.1.tar.gz
# cd jq-1.7.1
# apt install -y autoconf libtool
# autoreconf -i
# ./configure
# make
# sudo make install
# ln -s /usr/local/bin/jq /usr/bin/jq 

# Download and install NodeJS.
aws s3 cp s3://system-sharedresources-ssms3bucket-ad5ymdxwx113/bamboo-elastic-agent/node-v14-18-2/node-v14.18.2-linux-x64.tar.gz - | sudo tar -v -xz -C /opt/ 
aws s3 cp s3://system-sharedresources-ssms3bucket-ad5ymdxwx113/bamboo-elastic-agent/node-v18-18-2/node-v18.18.2-linux-x64.tar.gz - | sudo tar -v -xz -C /opt/ 
export PATH=$PATH:/opt/node-v14.18.2-linux-x64/bin
sudo npm install --global yarn
sudo echo 'export PATH=/opt/node-v14.18.2-linux-x64/bin:$PATH' >> /etc/profile.d/bamboo.sh

curl -fL https://getcli.jfrog.io | sh && sudo mv jfrog /usr/bin/ && sudo chmod +x /usr/bin/jfrog

echo "Set maven, java and ant home directories in PATH"
sudo sed -i 's/^export JAVA_HOME.*/export JAVA_HOME=\/opt\/amazon-corretto-8.332.08.1-linux-x64/' /etc/profile.d/bamboo.sh
sudo sed -i 's/^export M2_HOME.*/export M2_HOME=\/opt\/apache-maven-3.9.4/' /etc/profile.d/bamboo.sh
sudo sed -i 's/^export MAVEN_HOME.*/export MAVEN_HOME=\/opt\/apache-maven-3.9.4/' /etc/profile.d/bamboo.sh
echo "Fix Bamboo elastic agent heap size(XMX)"
sudo sed -i 's@.*MARKER.*@sed -i "s/-Xmx256m/-Xmx1g/" $startupScript@' /opt/bamboo-elastic-agent/bin/bamboo-elastic-agent

sudo echo 'export PATH=/opt/amazon-corretto-11.0.19.7.1-linux-x64/bin:/opt/apache-maven-3.9.4/bin:$PATH' >> /etc/profile.d/bamboo.sh

echo "Add private key to bamboo home directory"
sudo echo "export MAVEN_HOME=/opt/apache-maven-3.9.4" >> /etc/profile.d/bamboo.sh
echo "Setting maven home"
sudo mkdir -p /home/bamboo/.ssh
sudo echo "StrictHostKeyChecking no" >> /home/bamboo/.ssh/config
sudo aws secretsmanager get-secret-value --secret-id BambooElasticInstancePrivat-lnGWOmW8ChWA --region eu-west-1 --output text --query 'SecretString' > /home/bamboo/.ssh/id_rsa
sudo chown -R bamboo:bamboo /home/bamboo/.ssh
sudo chmod 400 /home/bamboo/.ssh/id_rsa

sudo echo "fs.file-max=1000000" >> /etc/sysctl.conf

sudo echo "bamboo           soft    nofile          900000" >> /etc/security/limits.conf
sudo echo "bamboo           hard    nofile          900000" >> /etc/security/limits.conf

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

aws ec2 create-tags --resources $instance_id --region eu-west-1 --tags \
Key=ct-aws:cloudformation:stack-name,Value=System-Atlassian \
Key=role,Value=bamboo-agent

su -c "mkdir -p /home/bamboo/bamboo-agent-home/logs" bamboo
su -c "chown -R bamboo:users /home/bamboo/bamboo-agent-home" bamboo
echo "Completed custom changes"
