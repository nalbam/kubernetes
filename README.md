## basic
```
cat ~/.kube/config

kubectl config view

# watch all namespaces
watch kubectl get deploy,pod,svc,ing,job,pvc,pv --all-namespaces

# get tunnel ip
ifconfig tunl0 | grep inet | awk '{print $2}'
```

## role
```
kubectl apply -f role/default.yml
kubectl apply -f role/nalbam.yml

kubectl get sa --all-namespaces | grep -E 'default|nalbam'
kubectl get clusterrole | grep cluster-admin
kubectl get clusterrolebindings | grep -E 'default|nalbam'

kubectl describe clusterrole cluster-admin
kubectl describe clusterrolebindings cluster-admin:default:default
kubectl describe clusterrolebindings cluster-admin:default:nalbam
```

## helm
```
helm init
helm ls

cd pipeline
helm dependency build
```

## sample
```
kubectl apply -f sample/sample-node.yml
kubectl apply -f sample/sample-spring.yml
kubectl apply -f sample/sample-web.yml

kubectl get deploy,pod,svc,ing,job,pvc,pv -n default

kubectl describe pod sample-web
```

## volume
```
kubectl apply -f volume/pv-5g.yml
kubectl apply -f volume/pv-10g.yml
```

## gitlab-ce (helm)
```
helm install -n gg -f charts/gitlab-ce.yaml stable/gitlab-ce
helm history gg
helm upgrade gg -f charts/gitlab-ce.yaml stable/gitlab-ce
helm delete --purge gg
```

## pipeline (helm)
```
helm install -n pp -f pipeline/values.yaml pipeline
helm history pp
helm upgrade pp -f pipeline/values.yaml pipeline
helm delete --purge pp

kubectl exec -it $(kubectl get pod | grep pp-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod | grep pp-sonatype-nexus | awk '{print $1}') -- sh
```
* https://helm.sh/
* https://github.com/kubernetes/helm
* https://github.com/kubernetes/charts
* https://github.com/CenterForOpenScience/helm-charts

## cleanup
```
helm delete --purge pp
kubectl delete -f volume/pv-5g.yml
kubectl delete -f volume/pv-10g.yml
sudo rm -rf /data/0*

docker rmi -f $(docker images -q)
```

## heapster
```
ADDON=addons/.temp.yml
cp -rf addons/heapster.yml ${ADDON}

kubectl apply -f ${ADDON}

watch kubectl top pod -n kube-system
watch kubectl top pod --all-namespaces
```
* https://github.com/kubernetes/heapster/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md

## dashboard
```
ADDON=addons/.temp.yml
cp -rf addons/dashboard.yml ${ADDON}

SSL_CERT_ARN=$(aws acm list-certificates | jq '.CertificateSummaryList[] | select(.DomainName=="nalbam.com")' | grep CertificateArn | cut -d'"' -f4)

sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" "${ADDON}"

kubectl apply -f ${ADDON}

# get dashboard token
kubectl describe secret -n kube-system $(kubectl get secret -n kube-system | grep kubernetes-dashboard-token | awk '{print $1}')

kubectl proxy --port=8080 &

http://localhost:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
http://master.nalbam.com:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
* https://github.com/kubernetes/dashboard/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md

## ingress-nginx
```
ADDON=addons/.temp.yml
cp -rf addons/ingress-nginx.yml ${ADDON}

SSL_CERT_ARN=$(aws acm list-certificates | jq '.CertificateSummaryList[] | select(.DomainName=="nalbam.com")' | grep CertificateArn | cut -d'"' -f4)

sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" "${ADDON}"

kubectl apply -f ${ADDON}

# ingress-nginx 에서 ELB Name 을 획득
ELB_NAME=$(kubectl get svc -n kube-ingress -owide | grep ingress-nginx | awk '{print $4}' | cut -d'-' -f1)

# ELB 에서 Hosted Zone ID, DNS Name 을 획득
ELB_ZONE_ID=$(aws elb describe-load-balancers --load-balancer-name ${ELB_NAME} | grep CanonicalHostedZoneNameID | cut -d'"' -f4)
ELB_DNS_NAME=$(aws elb describe-load-balancers --load-balancer-name ${ELB_NAME} | grep '"DNSName"' | cut -d'"' -f4)

# Route53 에서 해당 도메인의 Hosted Zone ID 를 획득
ZONE_ID=$(aws route53 list-hosted-zones | jq '.HostedZones[] | select(.Name=="nalbam.com.")' | grep '"Id"' | cut -d'"' -f4 | cut -d'/' -f3)

DOMAIN="sample-web.nalbam.com."

# temp file
RECORD=sample/.temp.json
cp -rf sample/record-sets.json ${RECORD}

# replace
sed -i -e "s@{{DOMAIN}}@${DOMAIN}@g" "${RECORD}"
sed -i -e "s@{{ELB_ZONE_ID}}@${ELB_ZONE_ID}@g" "${RECORD}"
sed -i -e "s@{{ELB_DNS_NAME}}@${ELB_DNS_NAME}@g" "${RECORD}"

# Route53 의 Record Set 에 입력/수정
aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://./${RECORD}
```
* https://github.com/kubernetes/ingress-nginx/
* https://github.com/kubernetes/kops/tree/master/addons/ingress-nginx

## cluster-autoscaler
```
ADDON=addons/.temp.yml
cp -rf addons/cluster-autoscaler.yml ${ADDON}

CLOUD_PROVIDER=aws
IMAGE=k8s.gcr.io/cluster-autoscaler:v1.1.2
MIN_NODES=2
MAX_NODES=5
AWS_REGION=ap-northeast-2
GROUP_NAME="nodes.kube.nalbam.com"
SSL_CERT_PATH="/etc/ssl/certs/ca-certificates.crt"

sed -i -e "s@{{CLOUD_PROVIDER}}@${CLOUD_PROVIDER}@g" "${ADDON}"
sed -i -e "s@{{IMAGE}}@${IMAGE}@g" "${ADDON}"
sed -i -e "s@{{MIN_NODES}}@${MIN_NODES}@g" "${ADDON}"
sed -i -e "s@{{MAX_NODES}}@${MAX_NODES}@g" "${ADDON}"
sed -i -e "s@{{GROUP_NAME}}@${GROUP_NAME}@g" "${ADDON}"
sed -i -e "s@{{AWS_REGION}}@${AWS_REGION}@g" "${ADDON}"
sed -i -e "s@{{SSL_CERT_PATH}}@${SSL_CERT_PATH}@g" "${ADDON}"

kubectl apply -f ${ADDON}
```
* https://github.com/kubernetes/autoscaler/
* https://github.com/kubernetes/kops/tree/master/addons/cluster-autoscaler
