output "master_ips" {
  value = aws_instance.master[*].private_ip
}

output "worker_ips" {
  value = aws_instance.worker[*].private_ip
}

output "ingress_ips" {
  value = aws_instance.ingress[*].private_ip
}
