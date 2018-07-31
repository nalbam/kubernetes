# Registry

## Docker Registry

```bash
kubectl get ing -n devops -o wide | grep docker-registry | awk '{print $2}'

curl -sL GET https://docker-registry-devops.demo.opspresso.com/v2/_catalog | jq

curl -sL GET https://docker-registry-devops.demo.opspresso.com/v2/sample-node/tags/list | jq

curl -sL GET https://docker-registry-devops.demo.opspresso.com/v2/sample-node/manifests/latest | jq
```

## Chartmuseum

```bash
kubectl get ing -n devops -o wide | grep chartmuseum | awk '{print $2}'

curl -sL https://chartmuseum-devops.demo.opspresso.com/api/charts | jq

helm ls
helm history sample-node-development

helm repo add chartmuseum https://chartmuseum-devops.demo.opspresso.com
helm repo update
helm repo list

helm search sample-node

helm install chartmuseum/sample-node --name sample-node
```
