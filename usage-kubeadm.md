# Kubeadm

## install

```bash
OS_NAME="$(uname | awk '{print tolower($0)}')"

VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

curl -LO https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/${OS_NAME}/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/${OS_NAME}/amd64/kubeadm
chmod +x kubeadm && sudo mv kubeadm /usr/local/bin/kubeadm

curl -LO https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/${OS_NAME}/amd64/kubelet
chmod +x kubelet && sudo mv kubelet /usr/local/bin/kubelet
```

## prepare

```bash
# docker insecure-registry
#vi /etc/sysconfig/docker
#INSECURE_REGISTRY='--insecure-registry 10.0.0.0/8 --insecure-registry pp-docker-registry:5000'

# docker cgroup
#docker info | grep -i cgroup
#vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice"

sudo swapoff -a

sudo systemctl daemon-reload
sudo systemctl restart kubelet

sudo kubeadm config images pull

sudo kubeadm reset
rm -rf $HOME/.kube $HOME/.helm $HOME/.draft
```

## start

```bash
LOCAL_IP=$(ip addr show | grep -Po 'inet \K[\d.]+' | grep '10.30')
echo ${LOCAL_IP}

sudo kubeadm init
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${LOCAL_IP}

mkdir -p $HOME/.kube
sudo cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Master Isolation
kubectl taint nodes --all node-role.kubernetes.io/master-

# Installing a pod network
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

# kubectl create cluster-role-binding
kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default
kubectl create clusterrolebinding cluster-admin:kube-public:default --clusterrole=cluster-admin --serviceaccount=kube-public:default

# kubectl get all
kubectl get all --all-namespaces

#ifconfig tunl0 | grep inet | awk '{print $2}'
```

* <https://kubernetes.io/docs/tasks/tools/install-kubectl/>
* <https://kubernetes.io/docs/setup/independent/install-kubeadm/>
* <https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/>
* <https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/>
* <https://amasucci.com/post/2017/10/22/how-to-install-kubernetes-1.8.1-on-centos-7.3/>

## stop

```bash
rm -rf $HOME/.kube

ls -al /usr/bin/ | grep kube
ls -al /usr/local/bin/ | grep kube
```
