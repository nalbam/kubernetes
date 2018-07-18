# Helm

## install

```bash
curl -sL toast.sh/helper/bastion.sh | bash
```

## usage

```bash
helm init

helm repo update
helm search
helm list

kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

# incubator
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
```

* <https://helm.sh/>
* <https://github.com/kubernetes/helm>
* <https://github.com/kubernetes/charts>

## charts

```bash
helm search jenkins
helm search nexus
helm search docker-registry
helm search chartmuseum

helm search prometheus
helm search grafana
```

## devops

```bash
pushd charts/devops
rm -rf charts requirements.lock
helm dependency build
popd

kubectl create namespace devops
kubectl create clusterrolebinding cluster-admin:devops:default --clusterrole=cluster-admin --serviceaccount=devops:default

helm install charts/devops -f charts/devops/values.yaml --name devops --namespace devops

kubectl get pod,svc,ing -n devops

#helm repo add chartmuseum http://devops-chartmuseum:8080

helm history devops
helm upgrade devops charts/devops -f charts/devops/values.yaml

helm rollback devops 1

helm delete --purge devops

kubectl logs $(kubectl get pod -n devops | grep devops-jenkins | awk '{print $1}') -n devops -f

kubectl exec -it $(kubectl get pod -n devops | grep devops-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod -n devops | grep devops-sonatype-nexus | awk '{print $1}') -- sh
```

## monitor

```bash
pushd charts/monitor
rm -rf charts requirements.lock
helm dependency build
popd

kubectl create namespace monitor
kubectl create clusterrolebinding cluster-admin:monitor:default --clusterrole=cluster-admin --serviceaccount=monitor:default

helm install charts/monitor -f charts/monitor/values.yaml --name monitor --namespace monitor

kubectl get pod,svc,ing -n monitor

helm history monitor
helm upgrade monitor charts/monitor -f charts/monitor/values.yaml

helm delete --purge monitor

# http://monitor-prometheus-server
# 1621
```
