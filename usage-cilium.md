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

# vars
export NAME=cluster.k8s.local

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
aws ec2 describe-images \
    --region "ap-northeast-2" \
    --owner "595879546273" \
    --filters "Name=virtualization-type,Values=hvm" "Name=name,Values=CoreOS-stable*" \
    --query "sort_by(Images,&CreationDate)[-1].{id:ImageLocation}" | jq .
```

```json
{
    "id": "595879546273/CoreOS-stable-1855.4.0-hvm"
}
```

## kops create

```bash
# create cluster
kops create=cluster \
    --state=${KOPS_STATE_STORE} \
    --node-size=t2.medium \
    --zones=ap-northeast-2a,ap-northeast-2c \
    --network-cidr=10.10.0.0/16 \
    --networking=cilium \
    --override="cluster.spec.etcdClusters[*].version=3.1.11" \
    --kubernetes-version=1.10.6 \
    --image="595879546273/CoreOS-stable-1855.4.0-hvm" \
    --topology=private \
    --cloud-labels="Team=Dev,Owner=Admin" \
    --name=${NAME}
```

## kops edit

```bash
# edit cluster
kops edit cluster --name=${NAME}
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
# update cluster
kops update cluster --name=${NAME} --yes

# validate cluster
kops validate cluster --name=${NAME}
```

## update cilium

```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/1.10/cilium-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/1.10/cilium-ds.yaml
kubectl set image daemonset/cilium -n kube-system cilium-agent=docker.io/cilium/cilium:v1.0.3
kubectl rollout status daemonset/cilium -n kube-system
```

## demo

```bash
# apply application
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.1/examples/minikube/http-sw-app.yaml

kubectl get pod,svc

# get cilium pod id
kubectl get pod -n kube-system -l k8s-app=cilium
CILIUM=$(kubectl get pod -n kube-system -l k8s-app=cilium | grep Running | head -1 | awk '{print $1}' | xargs)

# cilium endpoint list
kubectl exec ${CILIUM} -n kube-system -- cilium endpoint list

# request landing
kubectl exec xwing -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

# apply policy
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.1/examples/minikube/sw_l3_l4_policy.yaml

# retry landing
```

## apply rules

```bash
# get cnp (cilium-network-policies)
kubectl get cnp
kubectl describe cnp rule1

# exhaust-port
kubectl exec tiefighter -- curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port

kubectl get pod

# allow request-landing
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.1/examples/minikube/sw_l3_l4_l7_policy.yaml

# retry exhaust-port
# retry landing
```

## etc

```bash
kubectl get cs
kubectl get no
```

## kops delete

```bash
# delete cluster
kops delete cluster --name=${NAME} --yes
```

* <https://cilium.readthedocs.io/en/v1.2/kubernetes/install/kops/#k8s-install-kops>
* <https://ddiiwoong.github.io/2018/cilium-1/>
