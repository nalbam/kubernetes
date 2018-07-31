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

## basic

```bash
kubectl create namespace devops

helm install stable/jenkins --name jenkins --namespace devops \
             --values "charts/jenkins.yaml"

helm history jenkins
helm upgrade jenkins stable/jenkins -f charts/jenkins.yaml

helm rollback jenkins 1

helm delete --purge jenkins
```

## addons

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
