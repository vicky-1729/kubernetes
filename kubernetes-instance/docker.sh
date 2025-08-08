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