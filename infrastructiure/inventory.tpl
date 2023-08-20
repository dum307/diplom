[masters]
%{ for ip in masters ~}
${ip}
%{ endfor ~}

[workers]
%{ for ip in workers ~}
${ip}
%{ endfor ~}




[all]
%{ for i, ip in masters ~}
k8s-master-${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd${i + 1}
%{ endfor ~}
%{ for i, ip in workers ~}
k8s-worker-${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd${i + 1}
%{ endfor ~}
%{ for i, ip in ingresses ~}
k8s-ingress-${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd${i + 1}
%{ endfor ~}



