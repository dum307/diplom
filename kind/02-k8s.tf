data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "kind" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.medium"
    subnet_id = module.vpc.public_subnets[0]
    key_name = var.key_name
    #vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_api.id, aws_security_group.allow_ssh.id, aws_security_group.allow_https.id, aws_security_group.allow_https_webhook.id]
    vpc_security_group_ids = [aws_security_group.allow_http_ingress.id, aws_security_group.allow_api.id, aws_security_group.allow_ssh.id]
    associate_public_ip_address = true
    tags = {
    Name = "kind"
    }

    root_block_device {
      volume_size = 20
      volume_type = "gp2"
      delete_on_termination = true
    }
    
    connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file(var.private_key_file_path)
        host                = self.public_ip
    }

    provisioner "file" {
        source      = "kind_config.yaml"
        destination = "/tmp/kind_config.yaml"
    }

    provisioner "remote-exec" {
        script = "./init.sh"
    }

}






# resource "null_resource" "copy_kubeconfig" {
#   provisioner "local-exec" {
#       command = "sed -i 's/${aws_instance.master[0].private_ip}/${aws_instance.master[0].public_ip}/g' kubespray/inventory/k8s-cluster/artifacts/admin.conf && cp kubespray/inventory/k8s-cluster/artifacts/admin.conf ~/.kube/.kubeconfig"
#   }

#   depends_on = [
#     null_resource.install_k8s
#   ]
# }

# resource "null_resource" "install_ingress_controller" {
#   provisioner "local-exec" {
#       command = "kubectl --insecure-skip-tls-verify=true taint nodes k8s-ingress-0 node.kubernetes.io/ingress=:NoSchedule && helm install -f nginx-helm-vars.yaml ingress-nginx ingress-nginx/ingress-nginx --kube-insecure-skip-tls-verify"
#   }

#   depends_on = [
#     null_resource.copy_kubeconfig
#   ]
# }

