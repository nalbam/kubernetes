# Helm

## install

```bash
curl -sL toast.sh/helper/bastion.sh | bash
```

## usage

```bash
draft init
```

* <https://draft.sh/>
* <https://github.com/Azure/draft>

## pipeline (helm)

```bash
draft create --app sample-node

draft up

kubectl get pod,svc,ing -n default

helm ls
helm delete --purge sample-node
```
