#!/bin/bash

LOG_FILE="/tmp/k8s.log"
HOME="/home/centos"

# Step 1: Docker installation
sudo yum install -y yum-utils &>> ${LOG_FILE}
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &>> ${LOG_FILE}
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &>> ${LOG_FILE}
sudo systemctl start docker &>> ${LOG_FILE}
sudo systemctl enable docker &>> ${LOG_FILE}
sudo usermod -aG docker centos &>> ${LOG_FILE}

# Step 2: Download CRI DockerD interface
curl -LO https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.9/cri-dockerd-0.3.9-3.el8.x86_64.rpm &>> ${LOG_FILE}
sudo yum install cri-dockerd-0.3.9-3.el8.x86_64.rpm -y &>> ${LOG_FILE}

# Step 3: Perform Kubernetes installation
sudo cp ./kubernetes.repo /etc/yum.repos.d/kubernetes.repo

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes &>> ${LOG_FILE}
sudo systemctl enable --now kubelet &>> ${LOG_FILE}
sudo systemctl restart kubelet &>> ${LOG_FILE}

# Step 4: Delete the default config.toml and restart containerd service
# Necessary for K8s to work
sudo rm /etc/containerd/config.toml &>> ${LOG_FILE}
sudo systemctl restart containerd &>> ${LOG_FILE}

# Step 5: Create .kube directory
mkdir -p $HOME/.kube