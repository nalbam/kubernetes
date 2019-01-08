# Prometheus

## usage

```bash
# metrics
kubectl get --raw "/apis/metrics.k8s.io/v1beta1" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" | jq .

# custom metrics
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/dev/pods/*/cpu_usage" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/dev/pods/*/fs_usage_bytes" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/dev/pods/*/http_requests" | jq .

# sum (rate (container_cpu_usage_seconds_total{image!="",name=~"^k8s_.*"}[2m]) ) by (pod_name)
# sum (rate (container_network_receive_bytes_total{image!="",name=~"^k8s_.*"}[2m]) ) by (pod_name)

# node
sum (rate (container_cpu_usage_seconds_total{id="/",kubernetes_io_hostname=~"^$Node$"}[2m]))
sum (kube_pod_container_resource_requests_cpu_cores{kubernetes_node=~"^$Node$"})
sum (kube_pod_container_resource_limits_cpu_cores{kubernetes_node=~"^$Node$"})
sum (machine_cpu_cores{kubernetes_io_hostname=~"^$Node$"})
```

* <https://github.com/camilb/prometheus-kubernetes>
* <https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/>
* <https://itnext.io/kubernetes-monitoring-with-prometheus-in-15-minutes-8e54d1de2e13>
* <https://blog.2dal.com/2018/02/28/kubernetes-intro/>
