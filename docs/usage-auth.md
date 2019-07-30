# auth

## namespace

```bash
export NAMESPACE="demo"

# create namespace
kubectl create namespace ${NAMESPACE}
```

## user key

```bash
export USRENAME="nalbam"

# create private key
openssl genrsa -out ${USRENAME}.key 2048

# create certificate request
openssl req -new -key ${USRENAME}.key -subj "/CN=${USRENAME}/O=${USRENAME} corp" -out ${USRENAME}.csr

# create cert
openssl x509 -req -in ${USRENAME}.csr -CA /etc/kubernetes/ssl/ca.crt -CAkey /etc/kubernetes/ssl/ca.key -CAcreateserial -out ${USRENAME}.crt -days 10000
```

## create role

```bash
export ROLENAME="manager"

cat <<EOF > /tmp/role.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: ${ROLENAME}:${NAMESPACE}
  namespace: ${NAMESPACE}
rules:
  - apiGroups:
      - ""            # core api
      - "extensions"
      - "apps"
    resources:
      - "deployments"
      - "replicasets"
      - "pods"
      - "services"
    verbs:
      - "get"
      - "list"
      - "watch"
      - "create"
      - "update"
      - "patch"
      - "delete"
EOF

kubectl apply -f /tmp/role.yaml
```

## create rolebinding

```bash
cat <<EOF > /tmp/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: ${USRENAME}:${ROLENAME}:${NAMESPACE}
  namespace: ${NAMESPACE}
subjects:
  - kind: User         # User or ServiceAccount
    name: ${USRENAME}
roleRef:
  kind: Role
  name: ${ROLENAME}
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f /tmp/rolebinding.yaml
```
