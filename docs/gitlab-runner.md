# GitLab Runner

```bash
# sa
kubectl create sa gitlab-admin -n kube-system

# cluster role
kubectl create clusterrolebinding cluster-admin:kube-system:gitlab-admin --clusterrole=cluster-admin --serviceaccount=kube-system:gitlab-admin

# API server endpoint
kubectl cluster-info | grep 'Kubernetes master' | awk '/http/ {print $NF}'

# CA certificate
kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep default | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode

# Service Token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-admin | awk '{print $1}')
```

* <https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html>
