# karpenter

## eks cluster

```bash
export AWS_REGION="ap-northeast-2"

export CLUSTER_NAME="eks-demo"
export CLUSTER_EP=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.endpoint" --output json)
```

## install karpenter

```bash
# helm repo add karpenter https://charts.karpenter.sh
# helm repo update

helm upgrade --install --skip-crds karpenter karpenter/karpenter \
  --namespace addon-karpenter --create-namespace \
  --set serviceAccount.create=false \
  --set controller.clusterName=eks-demo \
  --set controller.clusterEndpoint=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.endpoint" --output json) \
  --wait # for the defaulting webhook to install before creating a Provisioner
```

## create karpenter provisioner

```bash
kubectl apply -f provisioner.yaml
```

## create app

```bash
kubectl create deployment --name inflate \
  --image=public.ecr.aws/eks-distro/kubernetes/pause:3.2

kubectl scale deployment inflate --replicas 10

kubectl logs -f -n addon-karpenter $(kubectl get pods -n addon-karpenter -l karpenter=controller -o name)
```
