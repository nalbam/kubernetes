## minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
  chmod +x minikube && sudo mv minikube /usr/local/bin/

minikube config set cpus 2
minikube config set memory 8GB
minikube config set vm-driver kvm2  # ubuntu
minikube config set vm-driver xhyve # mac

minikube start

eval $(minikube docker-env)

minikube dashboard

minikube service sample-web

watch kubectl get deploy,pod,svc,ing --all-namespaces

minikube stop
minikube delete
```
 * https://kubernetes.io/docs/tasks/tools/install-minikube/
 * https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/
