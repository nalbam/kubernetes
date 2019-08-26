# argo

* <https://argoproj.github.io/>
* <https://github.com/argoproj/>

## argo-workflow

* <https://github.com/argoproj/argo>

```bash
helm install argo/argo --name argo --namespace devops

kubectl create clusterrolebinding cluster-admin:default:default \
    --clusterrole=cluster-admin --serviceaccount=default:default

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/hello-world.yaml
argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/scripts-bash.yaml

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/arguments-parameters.yaml \
    -p message="goodbye world"

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/dag-diamond.yaml

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/ci.yaml
```

## argo-cd

* <https://github.com/argoproj/argo-cd>

```bash
# helm install argo/argo-cd --name argocd --namespace devops

kubectl create namespace devops
kubectl apply -n devops -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl create clusterrolebinding cluster-admin:devops:argocd-server \
    --clusterrole=cluster-admin --serviceaccount=devops:argocd-server

kubectl create clusterrolebinding cluster-admin:devops:argocd-application-controller \
    --clusterrole=cluster-admin --serviceaccount=devops:argocd-application-controller

# kubectl patch svc argocd-server -n devops -p '{"spec": {"type": "LoadBalancer"}}'
kubectl apply -n devops -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/argocd-ingress-spot.yml

USERNAME="admin"
PASSWORD="$(kubectl get pods -n devops -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f2)"
echo $PASSWORD

kubectl edit deploy argocd-server -n devops
- --insecure

# ARGOCD_SERVER="$(kubectl get svc -n devops argocd-server | grep LoadBalancer | awk '{print $4}')"
ARGOCD_SERVER="$(kubectl get ing -n devops argocd-server-grpc | grep argocd-server-grpc | awk '{print $2}')"

argocd login $ARGOCD_SERVER
argocd account update-password
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
