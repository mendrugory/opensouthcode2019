#!/bin/bash

cd "$(dirname "$0")/.."

. ./env.sh

# Admin IP
echo "Getting Admin IP"
export TF_VAR_admin_ip=$(curl https://ipinfo.io/ip)

echo "Creating Infrastructure"
terraform init
terraform apply -auto-approve

echo "Pointing to $TF_VAR_cluster_name"
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name $TF_VAR_cluster_name

echo "Adding Nodes to K8s..."
TERRAFORM_OUTPUT_FILE="/tmp/out"
K8S_ADD_NODES_FILE="/tmp/add_nodes.yml"

terraform output > $TERRAFORM_OUTPUT_FILE
tail -n +3 $TERRAFORM_OUTPUT_FILE > $K8S_ADD_NODES_FILE
kubectl apply -f $K8S_ADD_NODES_FILE
rm $TERRAFORM_OUTPUT_FILE $K8S_ADD_NODES_FILE
echo "Waiting for the nodes ..."
sleep 20
kubectl get nodes



echo "Installing Helm"
cd k8s/
kubectl create serviceaccount tiller --namespace kube-system
kubectl apply -f rbac.yaml
helm init --service-account tiller
helm repo update

WAITING=2
while [ $WAITING -ne 1 ]
do
    sleep 5
    echo "checking tiller ..."
    WAITING=$(kubectl get pods -n kube-system | awk '$1 ~ /tiller/ { if ($3 != "Running") {print 1; exit;}} END { print 0}' | wc -l)
done

sleep 10


echo "Ingress app ..."
kubectl create ns ingress

helm repo add akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/

helm install --name=alb \
    --namespace ingress \
    --set-string autoDiscoverAwsRegion=true \
    --set-string autoDiscoverAwsVpcID=true \
    --set clusterName=$TF_VAR_cluster_name \
    --set extraEnv.AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    --set extraEnv.AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    akomljen-charts/alb-ingress

echo "Launching K8S apps..."
SUBNETS=$(aws ec2 describe-subnets --filter Name=tag:Name,Values=${TF_VAR_cluster_name} --query "Subnets[*].SubnetId" --output text | tr "\\t" ",")
cp ingress.yaml.template ingress.yaml
sed -i -e 's/{SUBNETS}/'"$SUBNETS"'/g' ingress.yaml

kubectl apply -f database.yaml
sleep 120;
kubectl apply -f web.yaml
kubectl apply -f ingress.yaml