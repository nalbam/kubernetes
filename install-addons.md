## ingress-nginx
```bash
ADDON=addons/.temp.yml
cp -rf addons/ingress-nginx-v1.6.0-ssl.yml ${ADDON}

SSL_CERT_ARN=$(aws acm list-certificates | jq '[.CertificateSummaryList[] | select(.DomainName=="*.apps.nalbam.com")][0]' | grep CertificateArn | cut -d'"' -f4)

sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" "${ADDON}"

kubectl apply -f ${ADDON}

#kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/ingress-nginx-v1.6.0.yml

# ingress-nginx 의 ELB Name 을 획득
ELB_NAME=$(kubectl get svc -n kube-ingress -owide | grep ingress-nginx | grep LoadBalancer | awk '{print $4}' | cut -d'-' -f1)

# ELB 에서 Hosted Zone ID, DNS Name 을 획득
ELB_ZONE_ID=$(aws elb describe-load-balancers --load-balancer-name ${ELB_NAME} | grep CanonicalHostedZoneNameID | cut -d'"' -f4)
ELB_DNS_NAME=$(aws elb describe-load-balancers --load-balancer-name ${ELB_NAME} | grep '"DNSName"' | cut -d'"' -f4)

# Route53 에서 해당 도메인의 Hosted Zone ID 를 획득
ZONE_ID=$(aws route53 list-hosted-zones | jq '.HostedZones[] | select(.Name=="nalbam.com.")' | grep '"Id"' | cut -d'"' -f4 | cut -d'/' -f3)

DOMAIN="*.apps.nalbam.com."

# temp file
RECORD=sample/.temp.json
cp -rf sample/record-sets.json ${RECORD}

# replace
sed -i -e "s@{{DOMAIN}}@${DOMAIN}@g" "${RECORD}"
sed -i -e "s@{{ELB_ZONE_ID}}@${ELB_ZONE_ID}@g" "${RECORD}"
sed -i -e "s@{{ELB_DNS_NAME}}@${ELB_DNS_NAME}@g" "${RECORD}"

# Route53 의 Record Set 에 입력/수정
aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://./${RECORD}

# elb
kubectl get svc -o wide -n kube-ingress
```
* https://github.com/kubernetes/ingress-nginx/
* https://github.com/kubernetes/kops/tree/master/addons/ingress-nginx

## dashboard
```bash
ADDON=addons/.temp.yml
cp -rf addons/dashboard-v1.8.3-ing.yml ${ADDON}

#SSL_CERT_ARN=$(aws acm list-certificates | jq '[.CertificateSummaryList[] | select(.DomainName=="*.apps.nalbam.com")][0]' | grep CertificateArn | cut -d'"' -f4)

#sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" "${ADDON}"

kubectl apply -f ${ADDON}

#kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/dashboard-v1.8.3.yml

# admin
kubectl create serviceaccount admin -n kube-system
kubectl create clusterrolebinding cluster-admin:kube-system:admin --clusterrole=cluster-admin --serviceaccount=kube-system:admin

# get token
kubectl describe secret -n kube-system $(kubectl get secret -n kube-system | grep admin-token | awk '{print $1}')

# elb
kubectl get svc -o wide -n kube-system
```
* https://github.com/kubernetes/dashboard/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/tree/master/addons/kubernetes-dashboard

## heapster
```bash
ADDON=addons/.temp.yml
cp -rf addons/heapster-v1.7.0.yml ${ADDON}

kubectl apply -f ${ADDON}

#kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/heapster-v1.7.0.yml

kubectl top pod --all-namespaces
kubectl top pod -n kube-system
```
* https://github.com/kubernetes/heapster/
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/blob/master/addons/monitoring-standalone/

## cluster-autoscaler
```bash
ADDON=addons/.temp.yml
cp -rf addons/cluster-autoscaler-v1.8.0.yml ${ADDON}

CLOUD_PROVIDER=aws
IMAGE=k8s.gcr.io/cluster-autoscaler:v1.2.2
MIN_NODES=2
MAX_NODES=8
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

## route53-mapper (ExternalDNS)
```bash
kubectl apply -f addons/route53-mapper-v1.3.0.yml

kubectl top pod -n kube-system
kubectl top pod --all-namespaces
```
* https://github.com/kubernetes/kops/blob/master/docs/addons.md
* https://github.com/kubernetes/kops/tree/master/addons/route53-mapper
* https://github.com/kubernetes-incubator/external-dns
