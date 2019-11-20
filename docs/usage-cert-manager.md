# cert-manager

## install

```bash
# kubectl create namespace cert-manager

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml --validate=false

kubectl get all -n cert-manager
```

## install with helm

```bash
helm install --name cert-manager --namespace cert-manager stable/cert-manager
```

## cluster issuer

```bash
EMAIL="me@nalbam.com"

curl -sL https://raw.githubusercontent.com/nalbam/kubernetes/master/cert/cluster-issuer.yaml | \
  sed -e "s/email:.*/email: $EMAIL/g" | \
  kubectl apply -f-
```

## cluster issuer

```bash
export BASE_DOMAIN="demo.mzdev.be"

export PHASE="dev"
export NAMESPACE="sample-$PHASE"
export APPLICATION="sample-node"

# Certificate
sed -e "s/NAMESPACE/$NAMESPACE/g" cert/certificate.yaml | \
    sed -e "s/APPLICATION/$APPLICATION/g" | \
    sed -e "s/BASE_DOMAIN/$BASE_DOMAIN/g" | \
    sed -e "s/PHASE/$PHASE/g" | \
    kubectl apply -f-

# describe
kubectl get certificate -n $NAMESPACE
kubectl describe certificate $APPLICATION-$PHASE-tls -n $NAMESPACE

kubectl get secret -n $NAMESPACE | grep tls
kubectl describe secret $APPLICATION-$PHASE-tls -n $NAMESPACE
```

## ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: $APPLICATION-$PHASE
  namespace: $NAMESPACE
spec:
  rules:
  - host: $APPLICATION-$PHASE.$BASE_DOMAIN
    http:
      paths:
      - backend:
          serviceName: $APPLICATION-$PHASE
          servicePort: 8080
        path: /
  tls:
  - hosts:
    - $APPLICATION-$PHASE.$BASE_DOMAIN
    secretName: $APPLICATION-$PHASE
```
