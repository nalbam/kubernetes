# argo

* <https://argoproj.github.io/>
* <https://github.com/argoproj/argo>

## argo-workflow

* <https://github.com/argoproj/argo>

```bash
helm install argo/argo --name argo --namespace devops

argo submit https://raw.githubusercontent.com/nalbam/argo-example/master/workflows/hello-world.yaml
argo submit https://raw.githubusercontent.com/nalbam/argo-example/master/workflows/scripts-bash.yaml
argo submit https://raw.githubusercontent.com/nalbam/argo-example/master/workflows/steps.yaml

argo submit https://raw.githubusercontent.com/nalbam/argo-example/master/workflows/arguments-parameters.yaml -p message="goodbye world"

argo submit https://raw.githubusercontent.com/nalbam/argo-example/master/workflows/dag-diamond.yaml
```

## argo-cd

* <https://github.com/argoproj/argo-cd>

```bash
helm install argo/argo-cd --name argocd --namespace devops
```

## argo-events

* <https://github.com/argoproj/argo-events>

```bash
kubectl create namespace argo-events

# helm install argo/argo-events --name argo-events --namespace argo-events

kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/argo-events-cluster-roles.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/argo-events-sa.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/gateway-controller-configmap.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/gateway-controller-deployment.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/gateway-crd.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/sensor-controller-configmap.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/sensor-controller-deployment.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/sensor-crd.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/workflow-crd.yaml

kubectl apply -n argo-events -f https://raw.githubusercontent.com/nalbam/argo-example/master/events/webhook-event-sources.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/nalbam/argo-example/master/events/webhook-gateways.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/nalbam/argo-example/master/events/webhook-sensors.yaml

kubectl get pod,svc,ing -n argo-events

curl -d 'goodbye world' -X POST webhook-argo-events.demo.nalbam.com/example
curl -d '{"message":"this is my first webhook"}' -H "Content-Type: application/json" -X POST webhook-argo-events.demo.nalbam.com/example

argo list -n argo-events
```
