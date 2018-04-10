## minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
  chmod +x minikube && sudo mv minikube /usr/local/bin/

minikube config set cpus 2
minikube config set memory 8GB
minikube config set vm-driver kvm2

minikube start --vm-driver=kvm2  # ubuntu
minikube start --vm-driver=xhyve # mac

eval $(minikube docker-env)

minikube dashboard

minikube service sample-node

docker ps
docker images
```
 * https://kubernetes.io/docs/tasks/tools/install-minikube/
 * https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/
