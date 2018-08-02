# istio

## Amazon Web Services (AWS) with Kops

* <https://istio.io/docs/setup/kubernetes/platform-setup/aws/>

```bash
kops edit cluster --name kamino.k8s.local --state s3://kops-state-sbl
kops update cluster --yes
kops rolling-update cluster --yes
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
