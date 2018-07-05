#!/bin/bash

SHELL_DIR=$(dirname "$0")

CHOICE=

echo_() {
    echo -e "$1"
    echo "$1" >> /tmp/toast.log
}

success() {
    echo_ "$1"
    exit 0
}

error() {
    echo_ "$1"
    exit 1
}

menu() {
    # clear the screen
    tput clear

	# Move cursor to screen location X,Y (top left is 0,0)
	tput cup 3 10
	# Set a foreground colour using ANSI escape
	tput setaf 3
	echo "nalbam shell."
	tput sgr0

	tput cup 5 10
	# Set reverse video mode
	tput rev
	echo " K U B E - A D D O N S "
	tput sgr0

	tput cup 7 10
	echo "1. Metrics Server"

	tput cup 8 10
	echo "2. Ingress Nginx"

	tput cup 9 10
	echo "3. Dashboard"

	tput cup 10 10
	echo "4. Heapster (deprecated)"

	tput cup 11 10
	echo "5. Cluster Autoscaler"

	tput cup 13 10
	# Set bold mode
	tput bold
    read -p "Enter your choice [1-5] " CHOICE

	tput cup 17 0
}

apply_metrics_server() {
    if [ ! -d /tmp/metrics-server ]; then
        git clone https://github.com/kubernetes-incubator/metrics-server /tmp/metrics-server
    fi
    cd /tmp/metrics-server
    git pull
    kubectl apply -f metrics-server/deploy/1.8+/
}

apply_ingress_nginx() {
    ADDON=/tmp/ingress-nginx.yml

    read -p "Enter your ingress domain (ex: *.apps.nalbam.com) " DOMAIN

    if [ "${DOMAIN}" == "" ]; then
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/ingress-nginx-v1.6.0.yml
    else
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/ingress-nginx-v1.6.0-ssl.yml

        SSL_CERT_ARN=$(aws acm list-certificates | DOMAIN="${DOMAIN}" jq '[.CertificateSummaryList[] | select(.DomainName==env.DOMAIN)][0]' | grep CertificateArn | cut -d'"' -f4)

        if [ "${SSL_CERT_ARN}" == "" ]; then
            error "Empty CertificateArn."
        fi

        echo "CertificateArn: ${SSL_CERT_ARN}"

        sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" ${ADDON}
    fi

    kubectl apply -f ${ADDON}
}

apply_dashboard() {
    ADDON=/tmp/dashboard.yml

    read -p "Enter your ingress domain (ex: dashboard.apps.nalbam.com) " DOMAIN

    if [ "${DOMAIN}" == "" ]; then
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/dashboard-v1.8.3.yml
    else
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/dashboard-v1.8.3-ing.yml

        sed -i -e "s@dashboard.apps.nalbam.com@${DOMAIN}@g" ${ADDON}
    fi

    kubectl apply -f ${ADDON}
}

apply_heapster() {
    kubectl apply -f https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/heapster-v1.7.0.yml
}

apply_cluster_autoscaler() {
    ADDON=/tmp/cluster_autoscaler.yml

    curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/cluster-autoscaler-v1.8.0.yml

    CLOUD_PROVIDER=aws
    IMAGE=k8s.gcr.io/cluster-autoscaler:v1.2.2
    MIN_NODES=2
    MAX_NODES=8
    AWS_REGION=ap-northeast-2
    GROUP_NAME="nodes.kube.nalbam.com"
    SSL_CERT_PATH="/etc/ssl/certs/ca-certificates.crt"

    sed -i -e "s@{{CLOUD_PROVIDER}}@${CLOUD_PROVIDER}@g" "${ADDON}"
    sed -i -e "s@{{IMAGE}}@${IMAGE}@g" "${ADDON}"
    sed -i -e "s@{{MIN_NODES}}@${MIN_NODES}@g" "${ADDON}"
    sed -i -e "s@{{MAX_NODES}}@${MAX_NODES}@g" "${ADDON}"
    sed -i -e "s@{{GROUP_NAME}}@${GROUP_NAME}@g" "${ADDON}"
    sed -i -e "s@{{AWS_REGION}}@${AWS_REGION}@g" "${ADDON}"
    sed -i -e "s@{{SSL_CERT_PATH}}@${SSL_CERT_PATH}@g" "${ADDON}"

    kubectl apply -f ${ADDON}
}

menu
tput sgr0

case ${CHOICE} in
    1)
        apply_metrics_server
        ;;
    2)
        apply_ingress_nginx
        ;;
    3)
        apply_dashboard
        ;;
    4)
        apply_heapster
        ;;
    5)
        apply_cluster_autoscaler
        ;;
esac
