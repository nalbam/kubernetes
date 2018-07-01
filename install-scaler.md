## metrics-server

```bash
git clone https://github.com/kubernetes-incubator/metrics-server
kubectl apply -f metrics-server/deploy/1.8+/
```

```bash
ab -n 100000 -c 1 https://sample-spring.apps.nalbam.com/stress

ab -n 100000 -c 5 https://sample-spring.apps.nalbam.com/stress
```

```bash
kubectl get hpa
```
```
NAME            REFERENCE                  TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
sample-node     Deployment/sample-node     0%/50%    1         10        1          1h
sample-spring   Deployment/sample-spring   47%/50%   1         30        6          1h
sample-web      Deployment/sample-web      0%/50%    1         10        1          1h
```

* https://github.com/kubernetes-incubator/metrics-server
