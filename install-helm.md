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
helm ls
```
* https://helm.sh/
* https://github.com/kubernetes/helm
* https://github.com/kubernetes/charts

## nginx-ingress
```bash
helm install stable/nginx-ingress --name ingress

kubectl get svc ingress-nginx-ingress-controller -n default -o wide
kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/sample-node.yml
kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/sample-spring.yml
kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/sample-web.yml
```

## kubernetes-dashboard
```bash
helm install stable/kubernetes-dashboard --name dashboard
```

## heapster
```bash
helm install stable/heapster --name heapster
```

## prometheus
```bash
helm install stable/prometheus -f ./charts/prometheus.yml --name prometheus
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
