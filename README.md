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
    --cloud aws \
    --name ${KOPS_CLUSTER_NAME} \
    --state ${KOPS_STATE_STORE} \
    --zones ap-northeast-2a,ap-northeast-2c \
    --networking calico \
    --topology private \
    --bastion \
    --master-size t2.micro \
    --master-count 1 \
    --node-size t2.small \
    --node-count 2 \
    --dns-zone nalbam.com

kops get cluster

kops edit cluster ${KOPS_CLUSTER_NAME}

kops update cluster ${KOPS_CLUSTER_NAME} --yes

kops delete cluster ${KOPS_CLUSTER_NAME} --yes

ssh -i ~/.ssh/id_rsa admin@api.${KOPS_CLUSTER_NAME}
```
 * https://github.com/kubernetes/kops
 * https://kubernetes.io/docs/getting-started-guides/kops/
 * http://woowabros.github.io/experience/2018/03/13/k8s-test.html
