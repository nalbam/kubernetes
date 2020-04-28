# Registry

## Docker Registry

```bash
export REGISTRY=$(kubectl get ing -n devops -o wide | grep docker-registry | awk '{print $2}')
echo $REGISTRY

curl -sL https://$REGISTRY/v2/_catalog | jq '.'

curl -sL https://$REGISTRY/v2/sample-node/tags/list | jq '.'
curl -sL https://$REGISTRY/v2/sample-node/tags/list | jq -r '.tags[]' | sort -r
curl -sL https://$REGISTRY/v2/sample-node/tags/list | jq -r '.tags[]' | grep 'v0.0.' | sort -r | head -1
curl -sL https://$REGISTRY/v2/sample-node/manifests/latest | jq '.'

curl -sL https://hub.docker.com/v2/repositories/nalbam/sample-node/tags/ | jq -r '.results[].name' | grep 'v0.0.'
```

## Chartmuseum

```bash
export CHARTMUSEUM=$(kubectl get ing -n devops -o wide | grep chartmuseum | awk '{print $2}')
echo $CHARTMUSEUM

curl -sL https://$CHARTMUSEUM/api/charts | jq .

helm repo add chartmuseum https://$CHARTMUSEUM
helm repo update
helm repo list

helm search repo sample-node

helm install chartmuseum/sample-node --name sample-node --namespace sample --devel

helm ls -n sample
helm history sample-node
```
