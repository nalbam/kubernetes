#!/bin/bash

export USER=${USER:=$(whoami)}

install_dependency() {
    sudo yum repolist | grep rhui-REGION-rhel-server-extras
    if [ $? -eq 1 ]; then
      # for docker
      sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
    fi

    sudo yum repolist | grep epel
    if [ $? -eq 1 ]; then
      # for python2-pip, zile
      sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    fi

    sudo yum update -y
    sudo yum install -y git nano wget zip zile gettext net-tools libffi-devel docker \
                        python-cryptography python-passlib python-devel python-pip pyOpenSSL.x86_64 \
                        openssl-devel httpd-tools java-1.8.0-openjdk-headless NetworkManager \
                        "@Development Tools"
}

start_service() {
    sudo systemctl | grep "NetworkManager.*running"
    if [ $? -eq 1 ]; then
        sudo systemctl start NetworkManager
        sudo systemctl enable NetworkManager
    fi

    if [ "${USER}" != "root" ]; then
      sudo groupadd docker
      sudo usermod -aG docker ${USER}
    fi

    sudo systemctl restart docker
    sudo systemctl enable docker
}

install_dependency

start_service
