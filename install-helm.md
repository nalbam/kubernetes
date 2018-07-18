# Helm

## install

```bash
curl -sL toast.sh/helper/bastion.sh | bash
```

## usage

```bash
helm init

helm search
helm list

# incubator
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
```

* <https://helm.sh/>
* <https://github.com/kubernetes/helm>
* <https://github.com/kubernetes/charts>

## dependency build

```bash
pushd pipeline
helm dependency build
popd

helm search jenkins
helm search nexus
helm search docker-registry
helm search chartmuseum
```

## pipeline (helm)

```bash
kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

kubectl create namespace demo
kubectl create clusterrolebinding cluster-admin:demo:default --clusterrole=cluster-admin --serviceaccount=demo:default

helm install pipeline -f pipeline/values.yaml --name demo --namespace demo

helm repo add chartmuseum http://demo-chartmuseum:8080

helm history demo
helm upgrade demo pipeline -f pipeline/values.yaml

helm delete --purge demo

kubectl get pod,svc,ing -n demo

kubectl logs $(kubectl get pod -n demo | grep demo-jenkins | awk '{print $1}') -n demo -f

kubectl exec -it $(kubectl get pod -n demo | grep demo-jenkins | awk '{print $1}') -- sh
kubectl exec -it $(kubectl get pod -n demo | grep demo-sonatype-nexus | awk '{print $1}') -- sh
```

* <https://github.com/CenterForOpenScience/helm-charts>
