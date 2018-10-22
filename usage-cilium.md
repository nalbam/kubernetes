# Cilium

## install

```bash
curl -sL toast.sh/tools | bash
```

## AWS IAM

```bash
# Create IAM group named kops and grant access
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

# This flag is used to override the etcd version to be used from 2.X [kops default] to 3.1.x [requirement of cilium]
export KOPS_FEATURE_FLAGS=SpecOverrideFlag

# region
aws configure set default.region ap-northeast-2

# make bucket
aws s3 mb ${KOPS_STATE_STORE} --region ap-northeast-2
```

## get ami

```bash
aws ec2 describe-images --region=ap-northeast-2 --owner=595879546273 --filters "Name=virtualization-type,Values=hvm" "Name=name,Values=CoreOS-stable*" --query 'sort_by(Images,&CreationDate)[-1].{id:ImageLocation}'
```

```json
{
    "id": "595879546273/CoreOS-stable-1855.4.0-hvm"
}
```

## kops create

```bash
kops create cluster \
    --cloud aws \
    --name ${KOPS_CLUSTER_NAME} \
    --state ${KOPS_STATE_STORE} \
    --node-size t2.medium \
    --zones ap-northeast-2a,ap-northeast-2c \
    --network-cidr 10.10.0.0/16 \
    --networking cilium \
    --override "cluster.spec.etcdClusters[*].version=3.1.11" \
    --kubernetes-version 1.10.5 \
    --image 595879546273/CoreOS-stable-1855.4.0-hvm \
    --topology private \
    --cloud-labels "Team=Dev,Owner=Admin"
```

## kops edit

```bash
kops edit cluster --name ${KOPS_CLUSTER_NAME}
```

```yaml
spec:
  ...
  ...
  ...
  kubeAPIServer:
    featureGates:
      CustomResourceValidation: "true"
```

## kops update

```bash
kops update cluster --name=${KOPS_CLUSTER_NAME} --yes

kops validate cluster
```

## update cilium

```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/1.10/cilium-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/1.10/cilium-ds.yaml
kubectl set image daemonset/cilium -n kube-system cilium-agent=docker.io/cilium/cilium:v1.0.3
kubectl rollout status daemonset/cilium -n kube-system
```


* <https://cilium.readthedocs.io/en/v1.2/kubernetes/install/kops/#k8s-install-kops>
