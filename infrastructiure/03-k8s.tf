resource "aws_instance" "master" {
    count = var.master_count

    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = module.vpc.private_subnets[0]
    key_name = var.key_name
    # vpc_security_group_ids = var.template_security_group_ids
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
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
        inline = ["sudo hostnamectl set-hostname ${var.k8s_master_name}-${count.index}"]
    }

}


resource "aws_instance" "worker" {
    count = var.worker_count

    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = module.vpc.private_subnets[0]
    key_name = var.key_name
    #   vpc_security_group_ids = var.template_security_group_ids
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
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
    instance_type = "t2.micro"
    subnet_id = module.vpc.public_subnets[0]
    key_name = var.key_name
    #   vpc_security_group_ids = var.template_security_group_ids
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
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

locals {
  etcd_counter    = 1
}

resource "local_file" "inventory" {
  content = templatefile("./inventory.tpl",
    {
      masters   = aws_instance.master[*].private_ip
      workers   = aws_instance.worker[*].private_ip
      ingresses = aws_instance.ingress[*].private_ip
      etcd_counter = local.etcd_counter
    }
  )
  filename = "./inventory.ini"

  provisioner "local-exec" {
    command = "python3 edit_inventory.py && cp inventory.ini k8s-cluster/ && cp -r k8s-cluster kubespray/inventory/"
  }
}


resource "null_resource" "after_creation" {
  provisioner "local-exec" {
    command = "echo All resources have been created."
  }

  depends_on = [
    aws_instance.master,
    aws_instance.worker,
    aws_instance.ingress,
    local_file.inventory
  ]
}