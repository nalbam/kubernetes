# KOPS

## install

```bash
curl -sL toast.sh/tools | bash
```

## aws iam

```bash
aws iam create-group --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
aws iam create-user --user-name kops
aws iam add-user-to-group --user-name kops --group-name kops
aws iam create-access-key --user-name kops
```

## prepare

```bash
# ssh-key
ssh-keygen -q -f ~/.ssh/id_rsa -N ''

# var
export KOPS_CLUSTER_NAME=cluster.k8s.local
export KOPS_STATE_STORE=s3://kops-state-nalbam

# region
aws configure set default.region ap-northeast-2

# make bucket
aws s3 mb ${KOPS_STATE_STORE} --region ap-northeast-2
```

## kops

```bash
# create cluster
kops create cluster \
    --cloud=aws \
    --name=${KOPS_CLUSTER_NAME} \
    --state=${KOPS_STATE_STORE} \
    --node-size=m4.xlarge \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --network-cidr=10.10.0.0/16 \
    --networking=calico

#    --master-size=c4.large \
#    --master-count=3 \
#    --master-zones=ap-northeast-2a,ap-northeast-2c \
#    --node-count=2 \
#    --topology=private \
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

* <https://github.com/kubernetes/kops>
* <https://kubernetes.io/docs/getting-started-guides/kops/>

## insecure registry

```yaml
spec:
  docker:
    insecureRegistry: 100.64.0.0/10
    logDriver: ""
```

## kubectl

```bash
kubectl get node,deploy,pod,svc --all-namespaces
```
