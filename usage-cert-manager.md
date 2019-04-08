# cert-manager

## install

```bash
helm install --name cert-manager --namespace kube-system stable/cert-manager

export EMAIL="me@nalbam.com"

# ClusterIssuer
sed -e "s/email:.*/email: $EMAIL/g" cert/cluster-issuer.yaml | \
    kubectl apply -f-

export NAMESPACE="dev"
export APPLICATION="sample-node"
export BASE_DOMAIN="demo.opsnow.io"

# Certificate
sed -e "s/NAMESPACE/$NAMESPACE/g" cert/certificate.yaml | \
    sed -e "s/APPLICATION/$APPLICATION/g" | \
    sed -e "s/BASE_DOMAIN/$BASE_DOMAIN/g" | \
    kubectl apply -f-

# describe
kubectl get certificate -n $NAMESPACE
kubectl describe certificate $APPLICATION-$NAMESPACE-tls -n $NAMESPACE

kubectl get secret -n $NAMESPACE | grep tls
kubectl describe secret $APPLICATION-$NAMESPACE-tls -n $NAMESPACE
```

## ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: $APPLICATION-$NAMESPACE
spec:
  rules:
  - host: $APPLICATION-$NAMESPACE.$BASE_DOMAIN
    http:
      paths:
      - backend:
          serviceName: $APPLICATION-$NAMESPACE
          servicePort: 8080
        path: /
  tls:
  - hosts:
    - $APPLICATION-$NAMESPACE.$BASE_DOMAIN
    secretName: $APPLICATION-$NAMESPACE
```
