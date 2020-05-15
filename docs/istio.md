# istio

## istioctl

* <https://istio.io/docs/setup/install/istioctl/>

```bash
brew install istioctl

kubectl create ns istio-system

# install demo profile
istioctl manifest apply --set profile=demo
istioctl manifest generate --set profile=demo > istio-demo.yaml

# install demo profile with zipkin
istioctl manifest apply --set profile=demo --set values.tracing.provider=zipkin

# kubectl apply ingress or gateway
kubectl apply -f ./kubernetes/istio/ingress/
kubectl apply -f ./kubernetes/istio/gateway/

# delete demo
istioctl manifest generate --set profile=demo | kubectl delete -f -
```

## Examples

* <https://istio.io/docs/examples/bookinfo/>

```bash
kubectl label namespace default istio-injection=enabled
kubectl label namespace default istio-injection-

# apply
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/networking/bookinfo-gateway.yaml

GATEWAY_URL=$(kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}')
echo "http://${GATEWAY_URL}/productpage"

for i in `seq 1 100`; do curl -s -o /dev/null http://$GATEWAY_URL/productpage; done

kubectl get pod,svc

# delete
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.5/samples/bookinfo/networking/bookinfo-gateway.yaml
```

## Request Routing

```bash
# Apply dev destination rules
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/destination-rule-all.yaml

# Apply a virtual service
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml

# Route based on user identity (jason)
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

# Cleanup
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Fault Injection

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

# Injecting an HTTP delay fault (jason)
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

# Injecting an HTTP abort fault
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml

# Cleanup
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Traffic Shifting

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml

# Apply weight-based routing (50/50)
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

# Cleanup
kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

## Setting Request Timeouts

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/bookinfo/networking/virtual-service-all-v1.yaml

```

## Circuit Breaking

```bash
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/httpbin/httpbin.yaml
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.4/samples/httpbin/sample-client/fortio-deploy.yaml

# 컨넥션을 1만 허용함 - DestinationRule
kubectl apply -f ~/kubernetes/istio/sample/

FORTIO_POD=$(kubectl get pod | grep fortio-dev | awk '{ print $1 }')
echo $FORTIO_POD

kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -curl http://httpbin-dev/get
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -curl http://sample-node-dev/
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -curl http://sample-spring-dev/

# 컨넥션 2 보냄 - 에러가 발생
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin-dev/get
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://sample-spring-dev/fault/60

# 컨넥션 3 보냄 - 더 많은 에러
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 3 -qps 0 -n 20 -loglevel Warning http://httpbin-dev/get
kubectl exec -it $FORTIO_POD -c fortio /usr/local/bin/fortio -- load -c 3 -qps 0 -n 20 -loglevel Warning http://sample-spring-dev/fault/90

# apache benchmark
ab -n 1000000 -c 10 https://httpbin-dev.demo.nalbam.com/get
ab -n 1000000 -c 10 https://sample-spring-dev.demo.nalbam.com/fault/30
ab -n 1000000 -c 10 https://sample-spring-dev.demo.nalbam.com/fault/80

# Cleanup
kubectl delete destinationrule httpbin
kubectl delete deploy httpbin fortio-deploy
kubectl delete svc httpbin
```
