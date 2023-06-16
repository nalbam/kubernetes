# Prometheus

## usage

```bash
# metrics
kubectl get --raw "/apis/metrics.k8s.io/v1beta1" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" | jq .

# custom metrics
kubectl get --raw "/apis/external.metrics.k8s.io/v1beta1" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep "\"name\"" | sort
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep "\"name\"" | sort | grep container_network
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep "\"name\"" | sort | grep http_requests

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep "pods/" | sort
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq . | grep "namespaces/" | grep "pods/" | sort

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/sample/pods/*/cpu_usage" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/sample/pods/*/fs_usage_bytes" | jq .

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/sample/pods/*/http_requests" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/sample/services/*/http_requests" | jq .

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/sample/pods/*/nginx_ingress_controller_requests" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/sample/pods/*/container_network_receive_bytes" | jq .
```

```promql
# sum(rate(container_cpu_usage_seconds_total{image!="",name=~"^k8s_.*"}[2m])) by (pod_name)
# sum(rate(container_network_receive_bytes_total{image!="",name=~"^k8s_.*"}[2m])) by (pod_name)

# node
sum(rate(container_cpu_usage_seconds_total{id="/",kubernetes_io_hostname=~"^$Node$"}[2m]))
sum(kube_pod_container_resource_requests_cpu_cores{kubernetes_node=~"^$Node$"})
sum(kube_pod_container_resource_limits_cpu_cores{kubernetes_node=~"^$Node$"})
sum(machine_cpu_cores{kubernetes_io_hostname=~"^$Node$"})

# ingress
sum(rate(nginx_ingress_controller_requests{namespace=~\"$namespace\",ingress=~\"$ingress\",status!~\"[4-5].*\"}[2m]))
sum(rate(nginx_ingress_controller_requests{namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m]))

# node group
sum(kube_node_info)
kube_node_labels{label_group="worker"}

label_values(kube_node_labels, label_group)

sum(kube_pod_info * on (node) group_left (role) kube_node_labels{label_group=~"$node_group"}) /
sum(kube_node_status_allocatable_pods * on (node) group_left (role) kube_node_labels{label_group=~"$node_group"}) * 100

```

* <https://github.com/camilb/prometheus-kubernetes>
* <https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/>
* <https://itnext.io/kubernetes-monitoring-with-prometheus-in-15-minutes-8e54d1de2e13>
* <https://blog.2dal.com/2018/02/28/kubernetes-intro/>
