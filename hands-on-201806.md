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

### OSX
```
brew update && brew upgrage
brew install kops kubectl kubernetes-helm awscli jq
```
* https://brew.sh/index_ko

### Ubuntu
```
ssh -i path_of_key_pair.pem ubuntu@<IP-ADDRESS>
sudo passwd
su -

# prepare (root)
apt-get update && apt-get install -y apt-transport-https python-pip jq

# kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update && apt-get install -y kubectl
kubectl version

# kops
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://github.com/kubernetes/kops/releases/download/${VERSION}/kops-linux-amd64
chmod +x kops-linux-amd64 && sudo mv kops-linux-amd64 /usr/local/bin/kops
kops version

# helm
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz
tar -xvf helm-${VERSION}-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm
helm version

# awscli
pip install awscli --upgrade
aws --version
```

### Amazon AccessKeys
```
mkdir -p ~/.aws
mkdir -p ~/.ssh

pushd ~/.ssh
ssh-keygen -f id_rsa -N ''
popd

cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id=
aws_secret_access_key=
EOF

cat <<EOF > ~/.aws/config
[default]
region=ap-northeast-2
output=json
EOF

# test
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {InstanceId: .InstanceId, InstanceType: .InstanceType, State: .State.Name}'
```

## Create Kubernetes Cluster with kops (10m)
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

kops validate cluster

#kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
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
kubectl get deploy,pod,svc --all-namespaces
kubectl get deploy,pod,svc -n kube-system
kubectl get deploy,pod,svc -n default
```

## sample
``
git clone https://github.com/nalbam/kubernetes
``

### sample-node
```
kubectl apply -f kubernetes/hands-on-201806/sample-node.yml
kubectl delete -f kubernetes/hands-on-201806/sample-node.yml
```
* https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#LoadBalancers:sort=loadBalancerName

### heapster
```
kubectl apply -f kubernetes/hands-on-201806/heapster.yml
kubectl delete -f kubernetes/hands-on-201806/heapster.yml

kubectl top pod --all-namespaces
kubectl top pod -n kube-system
```
* https://github.com/kubernetes/heapster/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/blob/master/addons/monitoring-standalone/

### dashboard
```
kubectl apply -f kubernetes/hands-on-201806/dashboard.yml
kubectl delete -f kubernetes/hands-on-201806/dashboard.yml
```
* https://github.com/kubernetes/dashboard/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/tree/master/addons/kubernetes-dashboard
