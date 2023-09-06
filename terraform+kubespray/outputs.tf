output "master_private_ips" {
  value = aws_instance.master[*].private_ip
}

output "master_public_ips" {
  value = aws_instance.master[*].public_ip
}

output "worker_private_ips" {
  value = aws_instance.worker[*].private_ip
}

output "ingress_private_ips" {
  value = aws_instance.ingress[*].private_ip
}

output "ingress_public_ips" {
  value = aws_instance.ingress[*].public_ip
}


output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}