# Kubernetes

## basic

<details>

<summary>basic.yaml</summary>

```bash
cat ~/.kube/config

# kubectl cluster list
kubectl config view -o json | jq '.clusters[].name' -r

# kubectl config
kubectl config view

# kubectl cluster info
kubectl cluster-info

# kubectl context
kubectl config current-context
kubectl config use-context cluster.k8s.local

# kubectl change namespace
kubectl config set-context $(kubectl config current-context) --namespace=default

# kubectl api versions
kubectl api-versions

# kubectl get
kubectl get all --all-namespaces
kubectl get all -n default

kubectl get nodes --no-headers | \
  awk '{print $1}' | \
  xargs -I {} sh -c 'echo {}; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'

# kubectl exec bash
kubectl exec -n devops -it jenkins-74bd9c7799-jjkxz -- /bin/bash

# kubectl delete pod
kubectl delete pod -n devops -l jenkins=slave

# kubectl delete ns force
for ns in $(kubectl get ns --field-selector status.phase=Terminating -o jsonpath='{.items[*].metadata.name}'); do kubectl get ns $ns -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -; done

# get tunnel ip
ifconfig tunl0 | grep inet | awk '{print $2}'
```

</details>

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

docker rm $(docker ps -a -q)
docker rmi -f $(docker images -q)
```

```bash
dpkg -l | grep '^rc' | cut -d' ' -f3 | xargs sudo dpkg --purge
```
