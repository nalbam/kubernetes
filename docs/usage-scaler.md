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

kubectl get pod --all-namespaces -o wide | grep $NODE_ID

kubectl cordon $NODE_ID
kubectl uncordon $NODE_ID

kubectl drain --delete-emptydir-data --ignore-daemonsets --skip-wait-for-delete-timeout=0 $NODE_ID

kubectl get pod --all-namespaces -o wide | grep $NODE_ID

CA=$(kubectl get pod --all-namespaces | grep cluster-autoscaler | awk '{print $2}')
kubectl logs ${CA} -n addon-cluster-autoscaler -f

k get pod --all-namespaces | grep -v Running | grep -v Completed

k get no -l group=workers
k get no -l instancegroup=workers-v2

k get no -l instancegroup=workers-v2 | grep -v 'NAME' | awk '{print $1}'
k get no -l instancegroup=workers-v2 | grep -v 'NAME' | awk '{print $1}' | xargs -I {} kubectl cordon {}
k get no -l instancegroup=workers-v2 | grep -v 'NAME' | awk '{print $1}' | \
xargs -I {} kubectl drain --delete-emptydir-data --ignore-daemonsets --skip-wait-for-delete-timeout=0 {}

k get no --show-labels | grep v2 | awk '{print $1}'
k get no --show-labels | grep v2 | awk '{print $1}' | xargs -I {} kubectl cordon {}
k get no --show-labels | grep v2 | awk '{print $1}' | \
xargs -I {} kubectl drain --delete-emptydir-data --ignore-daemonsets --skip-wait-for-delete-timeout=0 {}
```
