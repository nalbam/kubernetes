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
kubectl get no -o wide

kubectl get pod --all-namespaces -o wide | grep ip-10-251-87-10.ap-northeast-2.compute.internal
kubectl get pod --all-namespaces -o wide | grep ip-10-251-87-59.ap-northeast-2.compute.internal
kubectl get pod --all-namespaces -o wide | grep ip-10-251-88-244.ap-northeast-2.compute.internal

kubectl drain ip-10-251-88-244.ap-northeast-2.compute.internal
kubectl uncordon ip-10-251-88-244.ap-northeast-2.compute.internal

kubectl get pod -o wide --all-namespaces | grep ip-10-251-88-244.ap-northeast-2.compute.internal

CA=$(kubectl get pod --all-namespaces | grep cluster-autoscaler | awk '{print $2}')
kubectl logs ${CA} -n kube-system -f
```
