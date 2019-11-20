# cert-manager

* <https://docs.cert-manager.io/>

## install

```bash
# kubectl create namespace cert-manager

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml --validate=false

kubectl get all -n cert-manager
```

## install with helm

```bash
helm install --name cert-manager --namespace cert-manager stable/cert-manager

kubectl get all -n cert-manager
```

## cluster issuer

```bash
export EMAIL="me@nalbam.com"

# cluster-issuer
curl -sL https://raw.githubusercontent.com/nalbam/kubernetes/master/cert-manager/cluster-issuer.yaml | \
  sed -e "s/email:.*/email: $EMAIL/g" | \
  kubectl apply -f-
```

## certificate

```bash
export BASE_DOMAIN="demo.mzdev.be"

export PHASE="dev"
export NAMESPACE="sample-$PHASE"
export APPLICATION="sample-node"

# certificate
curl -sL https://raw.githubusercontent.com/nalbam/kubernetes/master/cert-manager/certificate.yaml | \
  sed -e "s/NAMESPACE/$NAMESPACE/g" | \
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
