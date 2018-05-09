## agenda
* Prepare (kubectl, kops, helm)
* Create Kubernetes Cluster with kops
* Create pipeline with helm (jenkins, nexus, registry)
* Setup addons (dashboard, heapster)
* Build spring boot application

## prepare
### Amazon AccessKey
* https://console.aws.amazon.com/iam/home?region=ap-northeast-2#/home

### Amazon KeyPairs
* https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#KeyPairs:sort=keyName

### OSX (5m)
```
brew update && brew upgrade
brew install kops kubectl kubernetes-helm awscli jq
```
* https://brew.sh/index_ko

### Ubuntu (5m)
```
ssh -i path_of_key_pair.pem ubuntu@<IP-ADDRESS>
sudo passwd
su -

# prepare (1m)
apt-get update && apt-get install -y apt-transport-https python-pip jq

# kubectl (1m)
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update && apt-get install -y kubectl

# kops (2m)
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://github.com/kubernetes/kops/releases/download/${VERSION}/kops-linux-amd64
chmod +x kops-linux-amd64 && mv kops-linux-amd64 /usr/local/bin/kops

# helm (1m)
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz
tar -xvf helm-${VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm

# awscli (1m)
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

# aws config
cat <<EOF > ~/.aws/config
[default]
region=ap-northeast-2
output=json
EOF

# get ec2 list
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {InstanceId: .InstanceId, InstanceType: .InstanceType, State: .State.Name}'
```

## Create Kubernetes Cluster with kops (15m)
```
export KOPS_STATE_STORE=s3://kops-state-store-nalbam-seoul
export KOPS_CLUSTER_NAME=kube-hans-on-nalbam-seoul.k8s.local

# make state store
aws s3 mb ${KOPS_STATE_STORE}

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

## kubectl basic
```
cat ~/.kube/config

# kubectl config
kubectl config view

# kubectl get
kubectl get deploy,pod,svc,job --all-namespaces
kubectl get deploy,pod,svc,job -n kube-system
kubectl get deploy,pod,svc,job -n default

# ssh to the master
ssh -i ~/.ssh/id_rsa admin@api.${KOPS_CLUSTER_NAME}
```

## sample
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

### dashboard
Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters.
```
kubectl apply -f kubernetes/hands-on-201806/dashboard.yml

# create role binding for kubernetes-dashboard
kubectl create clusterrolebinding cluster-admin:kube-system:kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
kubectl get clusterrolebindings | grep cluster-admin

# get dashboard token
kubectl describe secret -n kube-system $(kubectl get secret -n kube-system | grep kubernetes-dashboard-token | awk '{print $1}')

# get elb list
aws elb describe-load-balancers | jq '.LoadBalancerDescriptions[] | {CanonicalHostedZoneName: .CanonicalHostedZoneName}'

kubectl delete -f kubernetes/hands-on-201806/dashboard.yml
```
* https://github.com/kubernetes/dashboard/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/tree/master/addons/kubernetes-dashboard

### heapster
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

## Helm
```
# create role binding for default
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

## pipeline (helm)
```
cd ~/kubernetes

helm install -n demo -f pipeline/values.yaml pipeline

helm history demo

helm upgrade demo -f pipeline/values.yaml pipeline

helm delete --purge demo

kubectl exec -it $(kubectl get pod | grep demo-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod | grep demo-sonatype-nexus | awk '{print $1}') -- sh
```
* https://github.com/CenterForOpenScience/helm-charts
