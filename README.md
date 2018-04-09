# kubernetes

* see: https://github.com/nalbam/basecamp/blob/master/kubernetes.md
* see: https://github.com/nalbam/basecamp/blob/master/kubernetes-addons.md

## sample
```
git clone https://github.com/nalbam/kubernetes.git
cd kubernetes

kubectl apply -f sample/sample-node.yml
kubectl apply -f sample/sample-spring.yml
kubectl apply -f sample/sample-web.yml

watch kubectl get node,pod,svc,ing -n default

kubectl describe pod sample-web
```
