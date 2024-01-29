#!/bin/bash

##############################################
#                                            #
#  AUTHOR = SORAV KUMAR SHARMA               #
#  SCRIPT NAME = K8s-Worker                  #
#  DESCRIPTION = The script install all the  #
#  required stuff that is needed to the      #
#  k8s worker/data node/plane.               #
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
