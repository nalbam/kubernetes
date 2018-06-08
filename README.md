## basic
```bash
cat ~/.kube/config

# kubectl config
kubectl config view

# change namespace
kubectl config set-context $(kubectl config current-context) --namespace=default

# kubectl get
watch kubectl get deploy,pod,svc,ing,job,cronjobs,pvc,pv --all-namespaces
watch kubectl get deploy,pod,svc,ing,job,cronjobs,pvc,pv -n default

# get tunnel ip
ifconfig tunl0 | grep inet | awk '{print $2}'
```

## role
```bash
kubectl apply -f role/default.yml
kubectl apply -f role/nalbam.yml

kubectl get sa --all-namespaces | grep -E 'default|nalbam'
kubectl get clusterrole | grep cluster-admin
kubectl get clusterrolebindings | grep cluster-admin

kubectl describe clusterrole cluster-admin
kubectl describe clusterrolebindings cluster-admin:default:default
kubectl describe clusterrolebindings cluster-admin:default:nalbam
```

## sample
```bash
kubectl apply -f sample/confog-map.yml

kubectl apply -f sample/sample-node.yml
kubectl apply -f sample/sample-spring.yml
kubectl apply -f sample/sample-web.yml

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

docker rm $(sudo docker ps -a -q)

docker rmi -f $(docker images -q)
docker rmi -f $(docker images | grep ' <none> ' | awk '{print $3}')
```
