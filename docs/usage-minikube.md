# minikube

## install

```bash
# minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
    && chmod +x minikube \
    && sudo mv minikube /usr/local/bin/

# kvm2
curl -Lo docker-machine-driver-kvm2 https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 \
    && chmod +x docker-machine-driver-kvm2 \
    && sudo mv docker-machine-driver-kvm2 /usr/local/bin/

# config
minikube config set cpus 4
minikube config set memory 4096
minikube config set vm-driver kvm2
minikube config set kubernetes-version v1.10.11
minikube config view
```

## start

```bash
minikube start
minikube start --cpus 4 --memory 4096
minikube start --vm-driver=kvm2 --kubernetes-version v1.10.11

eval $(minikube docker-env)

# addons
minikube addons list | grep enabled
minikube dashboard

kubectl get all --all-namespaces
```

## stop

```bash
minikube stop
minikube delete

rm -rf $HOME/.minikube $HOME/.kube $HOME/.helm $HOME/.draft
```

* <https://kubernetes.io/docs/tasks/tools/install-minikube/>
* <https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/>
* <https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver>
