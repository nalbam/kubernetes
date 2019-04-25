# knative

* <https://knative.dev/docs/install/knative-with-any-k8s/>

## Installing Istio

```bash
# kubectl apply -f https://github.com/knative/serving/releases/download/v0.5.0/istio-crds.yaml
# kubectl apply -f https://github.com/knative/serving/releases/download/v0.5.0/istio.yaml
```

```bash
kubectl label namespace default istio-injection=enabled
```

```bash
kubectl get pods --namespace istio-system
```

## Installing Knative

```bash
# kubectl apply -f https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml
# kubectl apply -f https://github.com/knative/serving/releases/download/v0.5.0/monitoring.yaml
# kubectl apply -f https://github.com/knative/build/releases/download/v0.5.0/build.yaml
# kubectl apply -f https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml
# kubectl apply -f https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml
# kubectl apply -f https://raw.githubusercontent.com/knative/serving/v0.5.0/third_party/config/build/clusterrole.yaml
```

```bash
kubectl apply -f https://github.com/knative/serving/releases/download/v0.5.2/serving.yaml
```

```bash
kubectl get pods --namespace knative-serving
# kubectl get pods --namespace knative-build
# kubectl get pods --namespace knative-eventing
# kubectl get pods --namespace knative-sources
# kubectl get pods --namespace knative-monitoring
```
