# GitLab Runner

```bash
kubectl create sa eks-admin -n kube-system

kubectl create clusterrolebinding cluster-admin:kube-system:eks-admin --clusterrole=cluster-admin --serviceaccount=kube-system:eks-admin

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep default | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```

* <https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html>
