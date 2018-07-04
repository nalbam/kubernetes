## install
```bash
# OSX
brew update && brew install kubernetes-helm

# Linux
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz
tar -xvf helm-${VERSION}-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm
```

## usage
```bash
helm init

helm search
helm list

# incubator
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
```
* https://helm.sh/
* https://github.com/kubernetes/helm
* https://github.com/kubernetes/charts

## elasticsearch
```bash
kubectl create namespace logging

helm install incubator/elasticsearch --name es --namespace logging

helm install stable/kibana --name kb --namespace logging
```


## dependency build
```bash
pushd pipeline
helm dependency build
popd
```

## pipeline (helm)
```bash
helm install -n demo -f pipeline/values.yaml pipeline
helm history demo
helm upgrade demo -f pipeline/values.yaml pipeline
helm delete --purge demo

kubectl exec -it $(kubectl get pod | grep demo-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod | grep demo-sonatype-nexus | awk '{print $1}') -- sh
```
* https://github.com/CenterForOpenScience/helm-charts
