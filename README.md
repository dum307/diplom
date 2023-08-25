# diplom


# Перед установкой кубернетеса.


sudo apt-get install python3.9-venv
python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

sudo cp kubectl /usr/local/bin/
cp admin.conf ~/.kube/.kubeconfig

helm install -f nginx-helm-vars.yaml ingress-nginx ingress-nginx/ingress-nginx --kube-insecure-skip-tls-verify
alias kubectl='kubectl --insecure-skip-tls-verify=true'
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission