# EFK

## install

```bash
git clone https://github.com/nalbam/kubernetes-efk
cd kubernetes-efk

./ctl.sh -i logging.apps.nalbam.com

kubectl get pod,svc,ing -n kube-logging
```
