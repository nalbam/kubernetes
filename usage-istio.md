# istio

## Amazon Web Services (AWS) with Kops

* <https://istio.io/docs/setup/kubernetes/platform-setup/aws/>

```bash
export NAME=cluster.k8s.local
export KOPS_STATE_STORE=s3://kops-state-nalbam

kops edit cluster --name=${NAME} --state=${KOPS_STATE_STORE}

kops update cluster --name=${NAME} --yes

kops rolling-update cluster --name=${NAME} --yes
```

```yaml
spec:
  kubeAPIServer:
    admissionControl:
    - NamespaceLifecycle
    - LimitRanger
    - ServiceAccount
    - PersistentVolumeLabel
    - DefaultStorageClass
    - DefaultTolerationSeconds
    - MutatingAdmissionWebhook
    - ValidatingAdmissionWebhook
    - ResourceQuota
    - NodeRestriction
    - Priority
```

## Installation steps

* <https://istio.io/docs/setup/kubernetes/helm-install/>

```bash
curl -sL https://git.io/getLatestIstio | sh -
cd istio-1.0.2

# namespace
kubectl create namespace istio-system

# crds (Custom Resource Definitions)
# kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
# kubectl apply -f install/kubernetes/helm/istio/charts/certmanager/templates/crds.yaml

# tiller
# kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
# helm init --service-account tiller

# install
helm upgrade --install istio install/kubernetes/helm/istio \
  --set ingress.enabled=true \
  --set grafana.enabled=true \
  --set servicegraph.enabled=true \
  --set tracing.enabled=true \
  --set kiali.enabled=true \
  --namespace istio-system

kubectl get pod,svc -n istio-system
kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}'

# delete
helm delete --purge istio

# kubectl delete -f install/kubernetes/helm/istio/templates/crds.yaml
# kubectl delete -f install/kubernetes/helm/istio/charts/certmanager/templates/crds.yaml
```

## Examples

* <https://istio.io/docs/examples/bookinfo/>

```bash
kubectl label namespace default istio-injection=enabled

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl get pod,svc,ing,gateway -n default
```
