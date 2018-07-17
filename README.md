# Kubernetes

## basic

```bash
cat ~/.kube/config

# kubectl cluster info
kubectl cluster-info

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
kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

kubectl get sa --all-namespaces | grep -E 'default|admin'
kubectl get clusterrole | grep cluster-admin
kubectl get clusterrolebindings | grep cluster-admin

kubectl describe clusterrole cluster-admin
kubectl describe clusterrolebindings cluster-admin:kube-system:default
```

## sample

```bash
kubectl apply -f sample/confog-map.yml

kubectl apply -f sample/sample-redis.yml

kubectl apply -f sample/sample-node-ing.yml
kubectl apply -f sample/sample-spring-ing.yml
kubectl apply -f sample/sample-tomcat-ing.yml
kubectl apply -f sample/sample-web-ing.yml

kubectl get deploy,pod,svc,ing -n default
kubectl describe pod sample-spring
```

## jobs

```bash
kubectl apply -f jobs/docker-clean.yml
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
