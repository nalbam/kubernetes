## install
```bash
# OSX
brew update && brew install kops

# Linux
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://github.com/kubernetes/kops/releases/download/${VERSION}/kops-linux-amd64
chmod +x kops-linux-amd64 && sudo mv kops-linux-amd64 /usr/local/bin/kops
```

## usage
```bash
# ssh-key
ssh-keygen -q -f ~/.ssh/id_rsa -N ''

# name
export KOPS_CLUSTER_NAME=kube.nalbam.com
export KOPS_STATE_STORE=s3://kops-nalbam-seoul

# region
aws configure set default.region ap-northeast-2

# make bucket
aws s3 mb ${KOPS_STATE_STORE} --region ap-northeast-2

# create hosted zone
# aws route53 create-hosted-zone --name ${KOPS_CLUSTER_NAME} --caller-reference 1

# create cluster
kops create cluster \
    --cloud=aws \
    --name=${KOPS_CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --master-size=t2.large \
    --node-size=t2.large \
    --node-count=2 \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --dns-zone=nalbam.com \
    --network-cidr=10.20.0.0/16 \
    --networking=calico

#    --target=terraform \
#    --out=.

kops get cluster

kops edit cluster --name=${KOPS_CLUSTER_NAME}

kops update cluster --name=${KOPS_CLUSTER_NAME} --yes

kops validate cluster --name=${KOPS_CLUSTER_NAME}

kops export kubecfg --name ${KOPS_CLUSTER_NAME}

kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
```
 * https://github.com/kubernetes/kops
 * https://kubernetes.io/docs/getting-started-guides/kops/

## kubectl
```bash
kubectl get deploy,pod,svc --all-namespaces
```
