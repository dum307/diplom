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
    vpc_security_group_ids = [aws_security_group.allow_http_ingress.id, aws_security_group.allow_ssh.id]
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

    # copy kind config
    provisioner "file" {
        source      = "kind_config.yaml"
        destination = "/home/ubuntu/kind_config.yaml"
    }

    # copy dockerconfig secret
    provisioner "file" {
        source      = ".dockerconfigjson"
        destination = "/home/ubuntu/.dockerconfigjson"
    }

    # copy env
    provisioner "file" {
        source      = ".env"
        destination = "/home/ubuntu/.env"
    }

    # copy jenkins casc config
    provisioner "file" {
        source      = "jenkins/casc_configs"
        destination = "/home/ubuntu/casc_configs"
    }

    # copy config jenkins for deploy in k8s
    provisioner "file" {
        source      = "jenkins/jenkins-sa-k8s.yaml"
        destination = "/home/ubuntu/jenkins-sa-k8s.yaml"
    }

    # copy config jenkins for deploy in k8s
    provisioner "file" {
        source      = "jenkins/jenkins-k8s.yaml"
        destination = "/home/ubuntu/jenkins-k8s.yaml"
    }

    # copy prometeus config
    provisioner "file" {
        source      = "../prometheus"
        destination = "/home/ubuntu/prometheus"
    }

    # start init script
    provisioner "remote-exec" {
        script = "./init.sh"
    }

}
