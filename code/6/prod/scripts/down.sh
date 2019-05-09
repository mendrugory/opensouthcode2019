#!/bin/bash

cd "$(dirname "$0")/.."

. ./env.sh
export TF_VAR_admin_ip=$(curl https://ipinfo.io/ip)

echo "Pointing to $TF_VAR_cluster_name"
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name $TF_VAR_cluster_name

kubectl delete -f k8s/ingress.yaml
kubectl delete -f k8s/web.yaml
kubectl delete -f k8s/database.yaml

echo "Destroying Infrastructure"
terraform destroy -auto-approve