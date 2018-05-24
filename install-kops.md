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
export KOPS_CLUSTER_NAME=kube.nalbam.com
export KOPS_STATE_STORE=s3://clusters.${KOPS_CLUSTER_NAME}

# make bucket
aws s3 mb ${KOPS_STATE_STORE}

# create hosted zone
aws route53 create-hosted-zone --name ${KOPS_CLUSTER_NAME} --caller-reference ${KOPS_CLUSTER_NAME}

# create cluster
kops create cluster \
    --cloud=aws \
    --name=${KOPS_CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --master-size=t2.small \
    --node-size=t2.medium \
    --node-count=2 \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --dns-zone=nalbam.com \
    --network-cidr=10.20.0.0/16 \
    --networking=calico

kops get cluster

kops edit cluster --name=${KOPS_CLUSTER_NAME}

kops update cluster --name=${KOPS_CLUSTER_NAME} --yes

kops validate cluster

kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
```
 * https://github.com/kubernetes/kops
 * https://kubernetes.io/docs/getting-started-guides/kops/
 * https://woowabros.github.io/experience/2018/03/13/k8s-test.html

## kubectl
```bash
# watch all namespaces
watch kubectl get deploy,pod,svc,ing,job,cronjobs,pvc,pv --all-namespaces
```
