#!/bin/bash

#Скачиваем kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git

#Запускаем Terraform
terraform apply -auto-approve

#Костыль! Редактируем inventory.ini
# python3 edit_inventory.py
# cp inventory.ini k8s-cluster/
# cp -r k8s-cluster kubespray/inventory/