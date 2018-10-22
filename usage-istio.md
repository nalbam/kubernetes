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
curl -L https://git.io/getLatestIstio | sh -
cd istio-1.1.0

# namespace
kubectl create namespace istio-system

# crds
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
kubectl apply -f install/kubernetes/helm/istio/charts/certmanager/templates/crds.yaml

# tiller
kubectl create -f install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller

# install
helm install install/kubernetes/helm/istio --name istio --namespace istio-system

helm delete --purge istio

kubectl get pod,svc,ing -n istio-system
kubectl get svc -n istio-system -o wide | grep istio-ingressgateway | awk '{print $4}'
```

## Sample

* <https://istio.io/docs/examples/bookinfo/>

```bash
kubectl label namespace default istio-injection=enabled

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl get pod,svc,gateway -n default
```
