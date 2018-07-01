## metrics-server

```bash
git clone https://github.com/kubernetes-incubator/metrics-server
cd metrics-server
kubectl apply -f deploy/1.8+/
```

```bash
ab -n 10000 -c 1 https://sample-spring.apps.nalbam.com/stress
```

```bash
kubectl get hpa
```

* https://github.com/kubernetes-incubator/metrics-server
