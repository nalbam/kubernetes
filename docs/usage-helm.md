# Helm

## install

```bash
curl -sL toast.sh/tools | bash
```

## usage

```bash
# kube-system tiller
kubectl create sa tiller -n kube-system

# cluster-admin kube-system tiller
kubectl create clusterrolebinding cluster-admin:kube-system:tiller \
    --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

# init
helm init --upgrade --service-account=tiller

helm list

# argo
helm repo add argo https://argoproj.github.io/argo-helm

# chartmuseum
export CHARTMUSEUM=$(kubectl get ing -n devops -o wide | grep chartmuseum | awk '{print $2}')
echo $CHARTMUSEUM

helm repo add chartmuseum https://${CHARTMUSEUM}

helm repo update
helm repo list

helm search

helm plugin install https://github.com/chartmuseum/helm-push
helm plugin list

# incubator
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
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

helm upgrade --install jenkins stable/jenkins -f charts/jenkins.yaml --namespace devops --devel

helm history jenkins

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
