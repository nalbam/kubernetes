# argo

* <https://argoproj.github.io/>
* <https://github.com/argoproj/argo>

## argo-workflow

```bash
helm install argo/argo --name argo --namespace devops

```

## argo-events

* <https://github.com/argoproj/argo-events>

```bash
# kubectl create namespace devops

helm install argo/argo-events --name argo-events --namespace devops

kubectl apply -n devops -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/event-sources/webhook.yaml
kubectl apply -n devops -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/gateways/webhook.yaml
kubectl apply -n devops -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/sensors/webhook.yaml

argo list -n devops
```
