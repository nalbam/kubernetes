# kubernetes

## kops install
```
export VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO https://github.com/kubernetes/kops/releases/download/${VERSION}/kops-linux-amd64 && \
 chmod +x kops-linux-amd64 && sudo mv kops-linux-amd64 /usr/local/bin/kops
```

## kops usage
```
export KOPS_CLUSTER_NAME=kube.nalbam.com
export KOPS_STATE_STORE=s3://clusters.kube.nalbam.com

aws route53 create-hosted-zone --name ${KOPS_CLUSTER_NAME} --caller-reference ${KOPS_CLUSTER_NAME}

aws s3 mb ${KOPS_STATE_STORE}

kops create cluster \
    --name ${KOPS_CLUSTER_NAME} \
    --state ${KOPS_STATE_STORE} \
    --master-size t2.micro \
    --node-size t2.small \
    --node-count 2 \
    --zones ap-northeast-2a,ap-northeast-2c \
    --dns-zone nalbam.com \
    --network-cidr 10.20.0.0/16 \
    --networking calico

kops get cluster

kops edit cluster ${KOPS_CLUSTER_NAME}

kops update cluster ${KOPS_CLUSTER_NAME} --yes

kops validate cluster

watch kubectl -n kube-system get pod,svc

kops delete cluster ${KOPS_CLUSTER_NAME} --yes
```
 * https://github.com/kubernetes/kops
 * https://kubernetes.io/docs/getting-started-guides/kops/
 * http://woowabros.github.io/experience/2018/03/13/k8s-test.html

## addons heapster
```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml

watch kubectl -n kube-system top pod
```
 * https://github.com/kubernetes/kops/blob/master/docs/addons.md
 * https://github.com/kubernetes/heapster

## addons dashboard
```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.3.yaml

kubectl -n kube-system get secret | grep dashboard
kubectl -n kube-system describe secret kubernetes-dashboard-token-xxxxx

kubectl proxy

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
 * https://github.com/kubernetes/dashboard

## sample
```
kubectl create -f sample/web.yml

```
