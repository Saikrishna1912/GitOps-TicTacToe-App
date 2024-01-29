#!/bin/bash

##############################################
#                                            #
#  AUTHOR = SORAV KUMAR SHARMA               #
#  SCRIPT NAME = K8s-Master                  #
#  DESCRIPTION = The script install all the  #
#  required resources that is needed to the  #
#  k8s master/control node/plane.            #
#                                            #
##############################################

set -e

#Setting hostname
echo "-------------Setting hostname-------------"
hostnamectl set-hostname $1

# Disable swap
echo "-------------Disabling swap-------------"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#Install docker
echo "-------------Installing Docker-------------"
sudo apt-get update 
sudo apt-get install -y docker.io

#Install kubectl, kubelet and kubeadm
echo "-------------Installing Kubectl, Kubelet and Kubeadm-------------"
apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update -y
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

#Install kube-apiserver
echo "-------------Installing kube-apiserver-------------"
sudo snap install kube-apiserver

echo "-------------Running kubeadm init-------------"
kubeadm init --pod-network-cidr=10.244.0.0/16

echo "-------------Copying Kubeconfig-------------"
mkdir -p $HOME/.kube
cp -iv /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) /root/.kube/config

echo "-------------Exporting Kubeconfig-------------"
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "-------------Deploying Flannel Pod Networking-------------"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "-------------Creating file with join command-------------"
echo `kubeadm token create --print-join-command` > ./worker_join.sh
