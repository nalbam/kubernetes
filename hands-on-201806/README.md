# Kubernetes Hands-on

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

**Index**

* [Prerequisites](#prerequisites)
* [Kubernetes Cluster](#kubernetes-cluster)
* [Addons](#addons)
* [Pipeline](#pipeline)
* [Build](#build) 

<!-- /TOC -->

## Prerequisites

### Amazon AccessKey
* https://console.aws.amazon.com/iam/home?region=ap-northeast-2#/home

### Amazon KeyPairs
* https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#KeyPairs:sort=keyName

### OSX (5m)
```
brew install kops kubectl kubernetes-helm awscli jq
```
* https://brew.sh/index_ko

### Ubuntu (5m)
```
# connect bastion
ssh -i path_of_key_pair.pem ubuntu@<IP-ADDRESS>

# kubectl (1m)
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF > kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo mv kubernetes.list /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubectl

# kops (2m)
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://github.com/kubernetes/kops/releases/download/${VERSION}/kops-linux-amd64
chmod +x kops-linux-amd64 && sudo mv kops-linux-amd64 /usr/local/bin/kops

# helm (1m)
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz
tar -xvf helm-${VERSION}-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm

# awscli (1m)
sudo apt-get install -y apt-transport-https python-pip jq
pip install awscli --upgrade
```

### Amazon AccessKeys
```
mkdir -p ~/.aws
mkdir -p ~/.ssh

# ssh key
pushd ~/.ssh
ssh-keygen -f id_rsa -N ''
popd

# aws credentials
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id=
aws_secret_access_key=
EOF

# aws set region
aws configure set default.region ap-northeast-2

# aws ec2 list
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {Id: .InstanceId, Ip: .PublicIpAddress, Type: .InstanceType, State: .State.Name}'

# aws elb list
aws elb describe-load-balancers | jq '.LoadBalancerDescriptions[] | {DNSName: .DNSName, Healthy: .HealthCheck.HealthyThreshold}'
```

## Kubernetes Cluster
```
export KOPS_STATE_STORE=s3://kops-state-store-nalbam-seoul
export KOPS_CLUSTER_NAME=kube-hans-on-nalbam-seoul.k8s.local

# aws s3 bucket for state store
aws s3 mb ${KOPS_STATE_STORE} --region ap-northeast-2

# create cluster
kops create cluster \
    --cloud=aws \
    --name=${KOPS_CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --master-size=t2.small \
    --node-size=t2.medium \
    --node-count=2 \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --network-cidr=10.20.0.0/16 \
    --networking=calico

kops get cluster

kops edit cluster --name=${KOPS_CLUSTER_NAME}

kops update cluster --name=${KOPS_CLUSTER_NAME} --yes

# validate cluster
kops validate cluster

kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
```
* https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#Instances:search=running;sort=tag:Name
* https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#LoadBalancers:sort=loadBalancerName
* https://ap-northeast-2.console.aws.amazon.com/ec2/autoscaling/home?region=ap-northeast-2#LaunchConfigurations:
* https://ap-northeast-2.console.aws.amazon.com/ec2/autoscaling/home?region=ap-northeast-2#AutoScalingGroups:view=details

### kubectl
```
# kubectl config
kubectl config view

# kubectl get
kubectl get deploy,pod,svc,job --all-namespaces
kubectl get deploy,pod,svc,job -n kube-system
kubectl get deploy,pod,svc,job -n default

# ssh to master
ssh -i ~/.ssh/id_rsa admin@13.125.209.87

# connect to cluster
scp admin@13.125.209.87:~/.kube/config ~/.kube/config

kubectl config set-cluster ${KOPS_CLUSTER_NAME} --server=https://${KOPS_CLUSTER_API}
kubectl config use-context ${KOPS_CLUSTER_NAME}
```

### sample
```
git clone https://github.com/nalbam/kubernetes

kubectl apply -f kubernetes/hands-on-201806/sample-node.yml
kubectl apply -f kubernetes/hands-on-201806/sample-spring.yml
kubectl apply -f kubernetes/hands-on-201806/sample-web.yml

kubectl delete -f kubernetes/hands-on-201806/sample-node.yml
kubectl delete -f kubernetes/hands-on-201806/sample-spring.yml
kubectl delete -f kubernetes/hands-on-201806/sample-web.yml
```
* https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#LoadBalancers:sort=loadBalancerName

## Addons

### Dashboard
Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters.
```
kubectl apply -f kubernetes/hands-on-201806/dashboard.yml

# create role binding for kube-system:kubernetes-dashboard
kubectl create clusterrolebinding cluster-admin:kube-system:kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
kubectl get clusterrolebindings | grep cluster-admin

# get dashboard token
kubectl describe secret -n kube-system $(kubectl get secret -n kube-system | grep kubernetes-dashboard-token | awk '{print $1}')

kubectl delete -f kubernetes/hands-on-201806/dashboard.yml
```
* https://github.com/kubernetes/dashboard/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/tree/master/addons/kubernetes-dashboard

### Heapster
Heapster enables Container Cluster Monitoring and Performance Analysis for Kubernetes
```
kubectl apply -f kubernetes/hands-on-201806/heapster.yml

kubectl top pod --all-namespaces
kubectl top pod -n kube-system

kubectl delete -f kubernetes/hands-on-201806/heapster.yml
```
* https://github.com/kubernetes/heapster/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/blob/master/addons/monitoring-standalone/

### Helm
```
# create role binding for kube-system:default
kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

# init
helm init --service-account default

helm search
helm list

kubectl edit deploy tiller-deploy -n kube-system

kubectl delete deploy tiller-deploy -n kube-system
kubectl delete service tiller-deploy -n kube-system
```
* https://helm.sh/
* https://github.com/kubernetes/helm
* https://github.com/kubernetes/charts

### Jenkins-X
```
export VERSION=$(curl -s https://api.github.com/repos/jenkins-x/jx/releases/latest | grep tag_name | cut -d'"' -f4)
curl -L https://github.com/jenkins-x/jx/releases/download/${VERSION}/jx-darwin-amd64.tar.gz | tar xzv 
sudo mv jx /usr/local/bin/

```
* https://jenkins-x.io/
* https://github.com/jenkins-x/jx

## Pipeline
```
cd ~/kubernetes

helm install -n demo -f pipeline/values.yaml pipeline

helm history demo

helm upgrade demo -f pipeline/values.yaml pipeline

helm delete --purge demo

# create role binding for default:default
kubectl create clusterrolebinding cluster-admin:default:default --clusterrole=cluster-admin --serviceaccount=default:default

kubectl exec -it $(kubectl get pod | grep demo-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod | grep demo-sonatype-nexus | awk '{print $1}') -- sh
```
* https://github.com/CenterForOpenScience/helm-charts

## Build
