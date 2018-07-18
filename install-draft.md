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

## gcr

```bash
ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
AUTH_TOKEN=$(echo "{\"registrytoken\":\"$ACCESS_TOKEN\"}" | base64 --wrap=0)

draft init --set \
    registry.url=gcr.io,\
    registry.org=${PROJECT},\
    registry.authtoken=${AUTH_TOKEN},\
    basedomain=${DOMAIN}
```
