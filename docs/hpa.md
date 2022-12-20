# hpa

## get hpa

```bash
kubectl get hpa -A -o json | \
  jq -r '.items[] | "\(.metadata.name) | \(.spec.targetCPUUtilizationPercentage) | \(.spec.minReplicas) | \(.spec.maxReplicas) | \(.status.currentReplicas)"'
```

## get deploy

```bash
kubectl get deploy -A -o json | \
  jq -r '.items[] | "\(.metadata.name) | \(.spec.template.spec.containers[0].resources.requests.cpu) | \(.spec.template.spec.containers[0].resources.requests.memory) | \(.spec.template.spec.containers[0].resources.limits.cpu) | \(.spec.template.spec.containers[0].resources.limits.memory)"'
```
