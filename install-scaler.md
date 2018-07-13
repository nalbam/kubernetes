# metrics-server

## install

```bash
git clone https://github.com/kubernetes-incubator/metrics-server
kubectl apply -f metrics-server/deploy/1.8+/
```

## sample

```bash
kubectl apply -f kubernetes/sample/sample-node-ing.yml
kubectl apply -f kubernetes/sample/sample-spring-ing.yml
kubectl apply -f kubernetes/sample/sample-web-ing.yml

kubectl get pod,svc,ing -n default
```

## auto scale

```bash
kubectl autoscale deployment sample-spring --min=2 --max=50 --cpu-percent=50
```

## stress

```bash
ab -n 1000000 -c 1 https://sample-spring.apps.nalbam.com/stress

ab -n 1000000 -c 10 https://sample-spring.apps.nalbam.com/stress
```

## result

```bash
kubectl get hpa
```

```bash
NAME            REFERENCE                  TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
sample-node     Deployment/sample-node     0%/50%    1         10        1          1h
sample-spring   Deployment/sample-spring   47%/50%   1         30        6          1h
sample-web      Deployment/sample-web      0%/50%    1         10        1          1h
```

```bash
kubectl describe hpa sample-spring
```

* <https://github.com/kubernetes-incubator/metrics-server>
