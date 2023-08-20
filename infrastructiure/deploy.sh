#!/bin/bash

#Скачиваем kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git

#Запускаем Terraform
terraform apply -auto-approve
