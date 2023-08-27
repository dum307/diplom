#!/bin/bash

# set hostname
sudo hostnamectl set-hostname kind

# install kubectl
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl


# install docker
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# install kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# create kind cluster
sudo kind create cluster --config /tmp/kind_config.yaml

# install nginx ingress controller
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# create github secret
sudo kubectl create namespace jenkins
sudo kubectl -n jenkins create secret generic github --from-file=.dockerconfigjson=/tmp/.dockerconfigjson --type=kubernetes.io/dockerconfigjson

# create jenkins SA and get token
sudo kubectl apply -f /tmp/jenkins-sa-k8s.yaml
export JENKINS_SA_TOKEN=$(sudo kubectl -n jenkins get secret jenkins-sa-token -o jsonpath='{.data.token}' | base64 --decode)
export GITHUB_PAT=$(cat .token)

# install jenkins
sleep 60
envsubst < /tmp/jenkins-k8s.yaml | sudo kubectl apply -f -
