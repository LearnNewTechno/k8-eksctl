#!/bin/bash

# disk partition
name=$(lsblk -dn -o NAME | head -n 1)

sudo growpart /dev/$name 4
sudo lvextend -L +10G /dev/RootVG/rootVol
sudo lvextend -L +10G /dev/mapper/RootVG-varVol
sudo lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

sudo xfs_growfs /
sudo xfs_growfs /var/tmp
sudo xfs_growfs /var

# kubectl install

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/kubectl

# etsctl install

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin

# Docker and docker compose install

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user