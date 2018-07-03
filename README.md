## basic
```bash
cat ~/.kube/config

# kubectl config
kubectl config view

# change namespace
kubectl config set-context $(kubectl config current-context) --namespace=default

# kubectl get
kubectl get deploy,pod,svc,ing,job,cronjobs,pvc,pv --all-namespaces
kubectl get deploy,pod,svc,ing,job,cronjobs,pvc,pv -n default

# get tunnel ip
ifconfig tunl0 | grep inet | awk '{print $2}'
```

## role
```bash
kubectl apply -f role/default-admin.yml

kubectl get sa --all-namespaces | grep -E 'default|admin'
kubectl get clusterrole | grep cluster-admin
kubectl get clusterrolebindings | grep cluster-admin

kubectl describe clusterrole cluster-admin
kubectl describe clusterrolebindings cluster-admin:default:admin
```

## sample
```bash
kubectl apply -f sample/confog-map.yml

kubectl apply -f sample/sample-node-ing.yml
kubectl apply -f sample/sample-spring-ing.yml
kubectl apply -f sample/sample-web-ing.yml

kubectl describe pod sample-web
```

## jobs
```bash
kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/jobs/docker-clean.yml
```

## volume
```bash
kubectl apply -f volume/pv-5g.yml
kubectl apply -f volume/pv-10g.yml
```

## cleanup
```bash
kubectl delete -f volume/pv-5g.yml
kubectl delete -f volume/pv-10g.yml

sudo rm -rf /data/0*

docker ps -a | awk '/Exited|Dead/ {print $1}' | xargs --no-run-if-empty docker rm
docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi
docker volume ls -q -f dangling=true | xargs --no-run-if-empty docker volume rmi
```
