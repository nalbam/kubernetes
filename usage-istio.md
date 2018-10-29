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

# crds (Custom Resource Definitions)
# kubectl apply -f ~/istio-1.0.2/install/kubernetes/helm/istio/templates/crds.yaml

# Install
helm upgrade --install istio ~/istio-1.0.2/install/kubernetes/helm/istio \
  --values ~/kubernetes/istio/istio.yaml \
  --namespace istio-system

kubectl get pod,svc,ing -n istio-system

INGRESS_GATEWAY=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}')
echo "http://${INGRESS_GATEWAY}"

# Cleanup
helm delete --purge istio
kubectl delete -f ~/istio-1.0.2/install/kubernetes/helm/istio/templates/crds.yaml
kubectl delete namespace istio-system
```

## Examples

* <https://istio.io/docs/examples/bookinfo/>

```bash
kubectl label namespace default istio-injection=enabled

kubectl apply -f ~/istio-1.0.2/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/bookinfo-gateway.yaml

INGRESS_GATEWAY=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}')
echo "http://${INGRESS_GATEWAY}/productpage"

kubectl get pod,svc,ing,hpa,gateway -n default

# Cleanup
kubectl delete -f ~/istio-1.0.2/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f ~/istio-1.0.2/samples/bookinfo/networking/bookinfo-gateway.yaml
```

## Request Routing

```bash
# Apply default destination rules
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/destination-rule-all.yaml

# Apply a virtual service
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml

# Route based on user identity (jason)
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

# Cleanup
kubectl delete -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Fault Injection

```bash
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

# Injecting an HTTP delay fault (jason)
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

# Injecting an HTTP abort fault
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml

# Cleanup
kubectl delete -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Traffic Shifting

```bash
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml

# Apply weight-based routing (50/50)
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

# Cleanup
kubectl delete -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Setting Request Timeouts

```bash
kubectl apply -f ~/istio-1.0.2/samples/bookinfo/networking/virtual-service-all-v1.yaml

```

## Circuit Breaking

```bash
# kubectl apply -f ~/istio-1.0.2/samples/httpbin/httpbin.yaml
# kubectl apply -f ~/istio-1.0.2/samples/httpbin/sample-client/fortio-deploy.yaml

# 컨넥션을 1만 허용함 - DestinationRule
kubectl apply -f ~/kubernetes/istio/sample/

FORTIO_POD=$(kubectl get pod | grep fortio-default | awk '{ print $1 }')
echo $FORTIO_POD

kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -curl http://httpbin-default/get
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -curl http://sample-node-default/
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -curl http://sample-spring-default/

# 컨넥션 2 보냄 - 에러가 발생
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin-default/get
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://sample-spring-default/fault/60

# 컨넥션 3 보냄 - 더 많은 에러
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 3 -qps 0 -n 20 -loglevel Warning http://httpbin-default/get
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 3 -qps 0 -n 20 -loglevel Warning http://sample-spring-default/fault/90

# apache benchmark
ab -n 1000000 -c 10 http://httpbin-default.demo.nalbam.com/get
ab -n 1000000 -c 10 http://sample-spring-default.demo.nalbam.com/fault/30
ab -n 1000000 -c 10 http://sample-spring-default.demo.nalbam.com/fault/80

# Cleanup
kubectl delete destinationrule httpbin
kubectl delete deploy httpbin fortio-deploy
kubectl delete svc httpbin
```
