# Helm

## install

```bash
curl -sL toast.sh/helper/bastion.sh | bash
```

## usage

```bash
helm init

helm list

helm repo add chartmuseum https://chartmuseum-devops.apps.opspresso.com
helm repo update
helm repo list

helm search

helm plugin install https://github.com/chartmuseum/helm-push
helm plugin list

kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

# incubator
#helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
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

## base

```bash
BASE_DOMAIN="apps.opspresso.com"
SSL_CERT_ARN=$(aws acm list-certificates | DOMAIN="*.${BASE_DOMAIN}" jq '[.CertificateSummaryList[] | select(.DomainName==env.DOMAIN)][0]' | grep CertificateArn | cut -d'"' -f4)

sed -i -e "s@aws-load-balancer-ssl-cert:.*@aws-load-balancer-ssl-cert: ${SSL_CERT_ARN}@" charts/nginx-ingress.yaml

# ingress-nginx
kubectl create namespace kube-ingress
helm install stable/nginx-ingress --name nginx-ingress --namespace kube-ingress \
             --values "charts/nginx-ingress.yaml"

kubectl get pod,svc -n kube-ingress
kubectl get svc --all-namespaces -o wide | grep nginx | grep ingress | grep LoadBalancer | awk '{print $5}' | head -1

# metrics-server
kubectl create namespace kube-metrics
helm install stable/metrics-server --name metrics-server --namespace kube-metrics

kubectl get pod,svc -n kube-metrics

# cluster-autoscaler
kubectl create namespace kube-autoscaler
helm install stable/cluster-autoscaler --name cluster-autoscaler --namespace kube-autoscaler \
             --values "charts/cluster-autoscaler.yaml" \
             --set "autoDiscovery.clusterName=ahsoka.k8s.local,awsRegion=ap-northeast-2"

kubectl get pod,svc -n kube-autoscaler


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

helm history devops
helm upgrade devops charts/devops -f charts/devops/values.yaml

helm rollback devops 1

helm delete --purge devops

kubectl logs $(kubectl get pod -n devops | grep devops-jenkins | awk '{print $1}' | head -1) -n devops -f

kubectl exec -it $(kubectl get pod -n devops | grep jenkins-slave | grep Running | awk '{print $1}' | head -1) -- sh
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
# Import: 1621
```
