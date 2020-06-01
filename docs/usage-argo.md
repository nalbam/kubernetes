# argo

* <https://argoproj.github.io/>
* <https://github.com/argoproj/>

## argo-workflow

* <https://github.com/argoproj/argo>

```bash
kubectl create namespace argo

# helm install argo/argo --name argo --namespace argo

kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml

kubectl apply -n argo -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/argo-ingress.yml

# kubectl create clusterrolebinding admin:argo:default --clusterrole=admin --serviceaccount=argo:default

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/hello-world.yaml
argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/scripts-bash.yaml

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/arguments-parameters.yaml \
    -p message="hello nalbam"

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/dag-diamond.yaml

argo submit https://raw.githubusercontent.com/argoproj/argo/master/examples/ci.yaml

argo submit https://raw.githubusercontent.com/nalbam/kubernetes/master/argo/ci.yaml
argo submit https://raw.githubusercontent.com/nalbam/kubernetes/master/argo/ci-build.yaml
argo submit https://raw.githubusercontent.com/nalbam/kubernetes/master/argo/ci-output-artifact.yaml
```

## argo-cd

* <https://github.com/argoproj/argo-cd>

```bash
kubectl create namespace argo

# helm install argo/argo-cd --name argocd --namespace argo

# kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.3.5/manifests/install.yaml

# kubectl create clusterrolebinding cluster-admin:argo:argocd-server \
#     --clusterrole=cluster-admin --serviceaccount=argo:argocd-server

# kubectl create clusterrolebinding cluster-admin:argo:argocd-application-controller \
#     --clusterrole=cluster-admin --serviceaccount=argo:argocd-application-controller

# kubectl patch svc argocd-server -n argo -p '{"spec": {"type": "LoadBalancer"}}'
kubectl apply -n argo -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/argocd-ingress.yml
kubectl apply -n argo -f https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/argocd-ingress-spot.yml

USERNAME="admin"
PASSWORD="$(kubectl get pods -n argo-cd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f2)"
echo $PASSWORD

kubectl edit deploy argocd-server -n argo
- --insecure

# ARGOCD_SERVER="$(kubectl get svc -n argo argocd-server | grep LoadBalancer | awk '{print $4}')"
ARGOCD_SERVER="$(kubectl get ing -n argo argocd-server-grpc | grep argocd-server-grpc | awk '{print $2}')"
echo $ARGOCD_SERVER

kubectl get pod,svc,ing -n argo

argocd login $ARGOCD_SERVER
argocd account update-password

# stable   https://kubernetes-charts.storage.googleapis.com/
# jetstack https://charts.jetstack.io/
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

## argo-rollouts

```bash
kubectl create namespace argo-rollouts

# kubectl apply argo-rollouts
kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml

# kubectl-argo-rollouts
curl -sLO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64 && \
chmod +x ./kubectl-argo-rollouts-darwin-amd64 && \
sudo mv ./kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts

# kubectl argo rollouts
kubectl argo rollouts get rollout sample-node -n demo-prod -w
```
