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
kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

helm init

helm search
helm list

# incubator
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
```
* https://helm.sh/
* https://github.com/kubernetes/helm
* https://github.com/kubernetes/charts

## jenkins
```bash
kubectl create namespace ops

helm install stable/jenkins -f charts/jenkins.yaml --name ops --namespace ops

helm history ops
helm upgrade ops stable/jenkins -f charts/jenkins.yaml

helm delete --purge ops

kubectl get pod,svc,ing -n ops
```

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
kubectl create namespace demo

helm install pipeline -f pipeline/values.yaml --name demo --namespace demo

helm history demo
helm upgrade demo pipeline -f pipeline/values.yaml

helm delete --purge demo

kubectl get pod,svc,ing -n demo

kubectl exec -it $(kubectl get pod | grep demo-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod | grep demo-sonatype-nexus | awk '{print $1}') -- sh
```
* https://github.com/CenterForOpenScience/helm-charts
