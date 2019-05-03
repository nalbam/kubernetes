# argo

* <https://argoproj.github.io/>
* <https://github.com/argoproj/argo>

## argo-events

```
kubectl create namespace argo-events

helm install argo/argo-events --name argo-events --namespace argo-events

kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/event-sources/webhook.yaml

kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/gateways/webhook.yaml

kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/sensors/webhook.yaml

argo list -n argo-events
```
