[all]
%{ for i, ip in masters ~}
k8s-master-${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd
%{ endfor ~}
%{ for i, ip in workers ~}
k8s-worker-${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd
%{ endfor ~}
%{ for i, ip in ingresses ~}
k8s-ingress-${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd
%{ endfor ~}


[kube_control_plane]
%{ for i, ip in masters ~}
k8s-master-${i}
%{ endfor ~}

[etcd]
%{ for i, ip in masters ~}
k8s-master-${i}
%{ endfor ~}


[kube_node]
%{ for i, ip in workers ~}
k8s-worker-${i}
%{ endfor ~}
%{ for i, ip in ingresses ~}
k8s-ingress-${i}
%{ endfor ~}

[kube_ingress]
%{ for i, ip in ingresses ~}
k8s-ingress-${i}
%{ endfor ~}

[k8s_cluster:children]
kube_control_plane
kube_node

