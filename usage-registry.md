# Registry

## Docker Registry

```bash
kubectl get ing -n devops -o wide | grep registry | awk '{print $2}'

curl -sL GET https://registry-devops.apps.opspresso.com/v2/_catalog | jq

curl -sL GET https://registry-devops.apps.opspresso.com/v2/sample-node-development/tags/list | jq

curl -sL GET https://registry-devops.apps.opspresso.com/v2/sample-node-development/manifests/latest | jq
```

## Chartmuseum

```bash
kubectl get ing -n chartmuseum -o wide | grep registry | awk '{print $2}'

curl -sL https://chartmuseum-devops.apps.opspresso.com/api/charts | jq

helm ls
helm history sample-node-development

helm repo add chartmuseum https://chartmuseum-devops.apps.opspresso.com
helm repo update
helm repo list

helm search sample-node

helm install chartmuseum/sample-node --name sample-node

```
