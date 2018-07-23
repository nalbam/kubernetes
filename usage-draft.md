# Draft

## install

```bash
curl -sL toast.sh/helper/bastion.sh | bash
```

## usage

```bash
draft init

draft config set registry registry-devops.apps.opspresso.com
draft config list
```

* <https://draft.sh/>
* <https://github.com/Azure/draft>

## pipeline (helm)

```bash
draft create -a sample-node

kubectl create namespace staging
kubectl create namespace production

draft up --docker-debug
draft up -e staging

kubectl get pod,svc,ing -n default
kubectl get pod,svc,ing -n staging

draft logs
draft delete

helm ls
helm history sample-node
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
