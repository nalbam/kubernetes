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

# vars
export NAME=cluster.k8s.local

export KOPS_STATE_STORE=s3://kops-state-nalbam

# region
aws configure set default.region ap-northeast-2

# make bucket
aws s3 mb ${KOPS_STATE_STORE} --region ap-northeast-2
```

## get ami

```bash
aws ec2 describe-images \
    --region "ap-northeast-2" \
    --owner "383156758163" \
    --filters "Name=virtualization-type,Values=hvm" "Name=name,Values=k8s-1.11-debian-jessie-amd64-hvm-ebs*" \
    --query "sort_by(Images,&CreationDate)[-1].{id:ImageLocation}" | jq .
```

```json
{
    "id": "383156758163/k8s-1.11-debian-jessie-amd64-hvm-ebs-2018-08-17"
}
```

## kops

```bash
# create cluster
kops create cluster \
    --state=${KOPS_STATE_STORE} \
    --node-size=m4.xlarge \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --network-cidr=10.10.0.0/16 \
    --networking=calico \
    --name=${NAME}

#    --master-size=c4.large \
#    --master-count=3 \
#    --master-zones=ap-northeast-2a,ap-northeast-2c \
#    --node-count=2 \
#    --topology=private \
#    --dns-zone=nalbam.com \
#    --kubernetes-version=1.11.5 \
#    --image="383156758163/k8s-1.11-debian-jessie-amd64-hvm-ebs-2018-08-17" \
#    --target=terraform \
#    --out=. \

# get cluster
kops get cluster --name=${NAME}

# edit cluster
kops edit cluster --name=${NAME}

# edit instance group
kops edit ig nodes --name=${NAME}

# update cluster
kops update cluster --name=${NAME} --yes

# rolling update cluster
kops rolling-update cluster --name=${NAME} --yes

# validate cluster
kops validate cluster --name=${NAME}

# export kube config
kops export kubecfg --name=${NAME}

# delete cluster
kops delete cluster --name=${NAME} --yes
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
