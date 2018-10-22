# Kubeadm

## install

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
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
```

## start

```bash
LOCAL_IP=$(ip addr show | grep -Po 'inet \K[\d.]+' | grep '10.30')
echo ${LOCAL_IP}

sudo kubeadm init
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${LOCAL_IP}

# auth
mkdir -p $HOME/.kube
sudo cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Master Isolation
kubectl taint nodes --all node-role.kubernetes.io/master-

# Installing a pod network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# kubectl create cluster-role-binding
kubectl create clusterrolebinding cluster-admin:kube-system:default --clusterrole=cluster-admin --serviceaccount=kube-system:default

#ifconfig tunl0 | grep inet | awk '{print $2}'
```

## test

```bash
# kubectl get all
kubectl get pod,svc,ing --all-namespaces

# docker-registry
curl -sL docker-registry.127.0.0.1.nip.io:30500/v2/_catalog | jq
curl -sL docker-registry.127.0.0.1.nip.io:30500/v2/sample-node-development/tags/list | jq
```

## stop

```bash
sudo kubeadm reset
rm -rf $HOME/.kube $HOME/.helm $HOME/.draft

ls -al /usr/bin/ | grep kube
ls -al /usr/local/bin/ | grep kube
```

* <https://kubernetes.io/docs/tasks/tools/install-kubectl/>
* <https://kubernetes.io/docs/setup/independent/install-kubeadm/>
* <https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/>
* <https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/>
* <https://amasucci.com/post/2017/10/22/how-to-install-kubernetes-1.8.1-on-centos-7.3/>
