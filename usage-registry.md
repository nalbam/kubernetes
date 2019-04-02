# Registry

## Docker Registry

```bash
export REGISTRY=$(kubectl get ing -n devops -o wide | grep docker-registry | awk '{print $2}')
echo $REGISTRY

curl -sL https://${REGISTRY}/v2/_catalog | jq '.'

curl -sL https://${REGISTRY}/v2/sample-node/tags/list | jq '.'
curl -sL https://${REGISTRY}/v2/sample-node/tags/list | jq -r '.tags[]' | sort
curl -sL https://${REGISTRY}/v2/sample-node/tags/list | jq -r '.tags[]' | grep 'v0.0.' | sort -r | head -1
curl -sL https://${REGISTRY}/v2/sample-node/manifests/latest | jq '.'
```

## Chartmuseum

```bash
export CHARTMUSEUM=$(kubectl get ing -n devops -o wide | grep chartmuseum | awk '{print $2}')
echo $CHARTMUSEUM

curl -sL https://${CHARTMUSEUM}/api/charts | jq .

helm ls
helm history sample-node-sample

helm repo add chartmuseum https://${CHARTMUSEUM}
helm repo update
helm repo list

helm search sample-node

helm install chartmuseum/sample-node --name sample-node --namespace default --devel
```
