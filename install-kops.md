## install
```bash
# OSX
brew update && brew install kops

# Linux
curl -sL toast.sh/helper/bastion.sh | bash
```

## usage
```bash
# ssh-key
ssh-keygen -q -f ~/.ssh/id_rsa -N ''

# name
export KOPS_CLUSTER_NAME=nalbam.k8s.local
export KOPS_STATE_STORE=s3://kops-nalbam-seoul

# region
aws configure set default.region ap-northeast-2

# make bucket
aws s3 mb ${KOPS_STATE_STORE} --region ap-northeast-2

# create cluster
kops create cluster \
    --cloud=aws \
    --name=${KOPS_CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --node-size=m4.large \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --network-cidr=10.10.0.0/16 \
    --networking=calico

#    --master-size=c4.large \
#    --master-count=3 \
#    --master-zones=ap-northeast-2a,ap-northeast-2c \
#    --node-count=2 \
#    --dns-zone=nalbam.com \
#    --kubernetes-version=1.11.0 \
#    --target=terraform \
#    --out=.

kops get cluster

# edit cluster
kops edit cluster

# edit instance group
kops edit ig nodes

kops update cluster --name=${KOPS_CLUSTER_NAME} --yes

kops rolling-update cluster --name=${KOPS_CLUSTER_NAME} --yes

# validate cluster
kops validate cluster

# export kube config
kops export kubecfg --name ${KOPS_CLUSTER_NAME}

kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
```
 * https://github.com/kubernetes/kops
 * https://kubernetes.io/docs/getting-started-guides/kops/

## kubectl
```bash
kubectl get node,deploy,pod,svc --all-namespaces
```
