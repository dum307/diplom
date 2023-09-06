resource "aws_instance" "master" {
    count = var.master_count

    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.small"
    subnet_id = module.vpc.public_subnets[0]
    key_name = var.key_name
    # vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_api.id, aws_security_group.allow_ssh.id, aws_security_group.allow_https.id, aws_security_group.allow_https_webhook.id]
    #vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_api.id, aws_security_group.allow_ssh.id]
    vpc_security_group_ids = [aws_security_group.allow_alll.id]
    associate_public_ip_address = true
    tags = {
    Name = "${var.k8s_master_name}-${count.index}"
    Hostname = "${var.k8s_master_name}-${count.index}"
    }

    connection {
        type                = "ssh"
        bastion_host        = aws_instance.bastion.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file(var.private_key_file_path)
        user                = "ubuntu"
        private_key         = file(var.private_key_file_path)
        host                = self.private_ip
    }

    provisioner "remote-exec" {
        inline = [
          "sudo hostnamectl set-hostname ${var.k8s_master_name}-${count.index}",
          "sudo bash -c 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash'"
        ]
    }

}


resource "aws_instance" "worker" {
    count = var.worker_count

    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.small"
    subnet_id = module.vpc.public_subnets[0]
    key_name = var.key_name
    # vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_ssh.id, aws_security_group.allow_https.id, aws_security_group.allow_https_webhook.id]
    #vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_ssh.id]
    vpc_security_group_ids = [aws_security_group.allow_alll.id]
    associate_public_ip_address = true
    tags = {
    Name = "${var.k8s_worker_name}-${count.index}"
    Hostname = "${var.k8s_worker_name}-${count.index}"
    }

    connection {
        type                = "ssh"
        bastion_host        = aws_instance.bastion.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file(var.private_key_file_path)
        user                = "ubuntu"
        private_key         = file(var.private_key_file_path)
        host                = self.private_ip
    }


    provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${var.k8s_worker_name}-${count.index}"]
    }

}

resource "aws_instance" "ingress" {
    count = var.ingress_count

    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.small"
    subnet_id = module.vpc.public_subnets[0]
    key_name = var.key_name
    #vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_ssh.id, aws_security_group.allow_http_ingress.id, aws_security_group.allow_https.id, aws_security_group.allow_https_webhook.id]
    #vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_ssh.id, aws_security_group.allow_http_ingress.id]
    vpc_security_group_ids = [aws_security_group.allow_alll.id]
    associate_public_ip_address = true
    tags = {
    Name = "${var.k8s_ingress_name}-${count.index}"
    Hostname = "${var.k8s_ingress_name}-${count.index}"
    }

    connection {
        type                = "ssh"
        bastion_host        = aws_instance.bastion.public_ip
        bastion_user        = "ubuntu"
        bastion_private_key = file(var.private_key_file_path)
        user                = "ubuntu"
        private_key         = file(var.private_key_file_path)
        host                = self.private_ip
    }


    provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${var.k8s_ingress_name}-${count.index}"]
    }

}

# generate inventory file for Ansible

# locals {
#   etcd_counter    = 1
# }

resource "local_file" "inventory" {
  content = templatefile("./inventory.tpl",
    {
      masters   = aws_instance.master[*].private_ip
      workers   = aws_instance.worker[*].private_ip
      ingresses = aws_instance.ingress[*].private_ip
      bastion   = aws_instance.bastion.public_ip
      # etcd_counter = local.etcd_counter
    }
  )
  filename = "./inventory.ini"

  provisioner "local-exec" {
      command = "python3 edit_inventory.py && cp inventory.ini k8s-cluster/ && cp -r k8s-cluster kubespray/inventory/"
  }
}


resource "null_resource" "install_k8s" {
  provisioner "local-exec" {
    command = "export ANSIBLE_ROLES_PATH=kubespray/roles/ && export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i kubespray/inventory/k8s-cluster/inventory.ini kubespray/cluster.yml -b --diff"
  }

  depends_on = [
    aws_instance.master,
    aws_instance.worker,
    aws_instance.ingress,
    local_file.inventory
  ]
}

resource "null_resource" "copy_kubeconfig" {
  provisioner "local-exec" {
      command = "sed -i 's/${aws_instance.master[0].private_ip}/${aws_instance.master[0].public_ip}/g' kubespray/inventory/k8s-cluster/artifacts/admin.conf && cp kubespray/inventory/k8s-cluster/artifacts/admin.conf ~/.kube/.kubeconfig"
  }

  depends_on = [
    null_resource.install_k8s
  ]
}

resource "null_resource" "install_ingress_controller" {
  provisioner "local-exec" {
      command = "kubectl --insecure-skip-tls-verify=true taint nodes k8s-ingress-0 node.kubernetes.io/ingress=:NoSchedule && helm install -f nginx-helm-vars.yaml ingress-nginx ingress-nginx/ingress-nginx --kube-insecure-skip-tls-verify"
  }

  depends_on = [
    null_resource.copy_kubeconfig
  ]
}

