# autoscaler

## hpa

### autoscale

```bash
kubectl autoscale deployment sample-spring --min=2 --max=50 --cpu-percent=50
```

### stress

```bash
ab -n 1000000 -c 1 https://sample-spring.demo.nalbam.com/stress
ab -n 1000000 -c 10 https://sample-spring.demo.nalbam.com/stress
```

### result

```bash
kubectl get hpa
```

## cluster autoscaler

```bash
export NAME=cluster.k8s.local
export KOPS_STATE_STORE=s3://kops-state-nalbam

kops edit cluster --name=${NAME} --state=${KOPS_STATE_STORE}

kops update cluster --name=${NAME} --yes

kops rolling-update cluster --name=${NAME} --yes
```

```yaml
spec:
  cloudLabels:
    k8s.io/cluster-autoscaler/enabled: ""
    kubernetes.io/cluster/dev.k8s.local: owned
```

```bash
kubectl get no -o wide

kubectl get pod --all-namespaces -o wide | grep ip-10-251-87-129

kubectl cordon ip-10-251-87-129.ap-northeast-2.compute.internal
kubectl uncordon ip-10-251-87-129.ap-northeast-2.compute.internal

kubectl drain --delete-local-data --ignore-daemonsets ip-10-251-87-129.ap-northeast-2.compute.internal

kubectl get pod -o wide --all-namespaces | grep ip-10-251-88-244

CA=$(kubectl get pod --all-namespaces | grep cluster-autoscaler | awk '{print $2}')
kubectl logs ${CA} -n addon-cluster-autoscaler -f

k get pod --all-namespaces | grep -v Running | grep -v Completed

k get no --show-labels
k get no --show-labels | grep 'group=worker' | grep 'v1.14.7' | cut -d' ' -f1

k get no --show-labels | grep 'group=worker' | grep 'v1.14.7' | cut -d' ' -f1 > /tmp/kube_nodes

k get no --show-labels | cut -d' ' -f1 | xargs -I {} k cordon {}

```
