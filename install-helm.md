## install
```
# OSX
brew update && brew install kubernetes-helm

# Linux
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | grep tag_name | cut -d'"' -f4)
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz
tar -xvf helm-${VERSION}-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/helm
```

## usage
```
helm init
helm ls

cd pipeline
helm dependency build
```
* https://helm.sh/
* https://github.com/kubernetes/helm
* https://github.com/kubernetes/charts

## pipeline (helm)
```
helm install -n demo -f pipeline/values.yaml pipeline
helm history demo
helm upgrade demo -f pipeline/values.yaml pipeline
helm delete --purge demo

kubectl exec -it $(kubectl get pod | grep demo-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod | grep demo-sonatype-nexus | awk '{print $1}') -- sh
```
* https://github.com/CenterForOpenScience/helm-charts

## addons (charts)
```
helm install stable/kubernetes-dashboard --name my-release
```
