# minikube

## install

```bash
curl -oL minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
  chmod +x minikube && \
  sudo mv minikube /usr/local/bin/minikube

minikube config set cpus 2
minikube config set memory 8
minikube config set vm-driver kvm2

minikube start

eval $(minikube docker-env)

minikube dashboard

minikube addons enable ingress

minikube service sample-web

kubectl get deploy,pod,svc,ing,job,pvc,pv -n default

minikube stop
minikube delete
```

* <https://kubernetes.io/docs/tasks/tools/install-minikube/>
* <https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/>
* <https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver>
