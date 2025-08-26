#!/bin/bash

dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Expand partition 4 to use new disk space
growpart /dev/nvme0n1 4

# Resize the physical volume to use the expanded partition
pvresize /dev/nvme0n1p4

# Extend logical volumes: add 20G to root, 10G to var
lvextend -L +20G /dev/RootVG/rootVol
lvextend -L +10G /dev/RootVG/varVol

# Grow XFS filesystems to use the new space
sudo xfs_growfs /
sudo xfs_growfs /var

# Install eksctl for EKS cluster creation
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl
eksctl version
# Install AWS CLI v2 [we taken aws ec2 so need to install aws cli v2]
# Install kubectl for cluster interaction
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version

#just download git repo
git clone https://github.com/vicky-1729/kubernetes.git