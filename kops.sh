#!/bin/bash

CHOICE=
CLUSTER=

REGION=

KOPS_STATE_STORE=
KOPS_CLUSTER_NAME=

cloud=aws
master_size=c4.large
master_count=1
master_zones=ap-northeast-2a
node_size=m4.large
node_count=2
zones=ap-northeast-2a,ap-northeast-2c
network_cidr=10.10.0.0/16
networking=calico

T_PAD=2
L_PAD=6

CONFIG=~/.kops/config
if [ -f ${CONFIG} ]; then
    . ${CONFIG}
fi

echo_() {
    echo -e "$1"
}

success() {
    echo_ "$1"
    exit 0
}

error() {
    echo_ "$1"
    exit 1
}

title() {
    # clear the screen
    tput clear

	# Set a foreground colour using ANSI escape
	tput setaf 3
	tput cup  3 ${L_PAD} && echo "KOPS UI"
	tput sgr0

	# Set reverse video mode
	tput rev
	tput cup  5 ${L_PAD} && echo " ${KOPS_STATE_STORE} > ${KOPS_CLUSTER_NAME} "
	tput sgr0
}

prepare() {
    title

	echo_

    mkdir -p ~/.kops

    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -q -f ~/.ssh/id_rsa -N ''
    fi

    # iam user
    IAM_USER=$(aws iam get-user | grep Arn | cut -d'"' -f4 | cut -d':' -f5)
    if [ "${IAM_USER}" == "" ]; then
        aws configure

        IAM_USER=$(aws iam get-user | grep Arn | cut -d'"' -f4 | cut -d':' -f5)
        if [ "${IAM_USER}" == "" ]; then
            clear
            error
        fi
    fi

    REGION=$(aws configure get profile.default.region)

    read_state_store

    read_cluster_no

#    echo "# kops config" > ${CONFIG}
#    echo "KOPS_STATE_STORE=${KOPS_STATE_STORE}" >> ${CONFIG}
#    echo "KOPS_CLUSTER_NAME=${KOPS_CLUSTER_NAME}" >> ${CONFIG}

    CLUSTER=$(kops get --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} | wc -l)
    cluster_menu
}

cluster_menu() {
    title

    if [ "${CLUSTER}" == "0" ]; then
    	tput cup  7 ${L_PAD} && echo "1. Create Cluster"
        tput cup  8 ${L_PAD} && echo "2. Install Tools"
    else
        tput cup  7 ${L_PAD} && echo "1. Get Cluster"
        tput cup  8 ${L_PAD} && echo "2. Edit Cluster"
        tput cup  9 ${L_PAD} && echo "3. Edit Instance Group"
        tput cup 10 ${L_PAD} && echo "4. Update Cluster"
        tput cup 11 ${L_PAD} && echo "5. Rolling Update Cluster"
        tput cup 12 ${L_PAD} && echo "6. Validate Cluster"
        tput cup 13 ${L_PAD} && echo "7. Export Kubernetes Config"
        tput cup 14 ${L_PAD} && echo "8. Addons"
        tput cup 15 ${L_PAD} && echo " "
        tput cup 16 ${L_PAD} && echo "0. Delete Cluster"
    fi

	# Set bold mode
	tput bold
    tput cup 18 ${L_PAD} && read -p "Enter your choice : " CHOICE
    tput sgr0

	echo_

    case ${CHOICE} in
        1)
            if [ "${CLUSTER}" == "0" ]; then
                create_cluster
            else
                get_cluster
            fi
            ;;
        2)
            if [ "${CLUSTER}" == "0" ]; then
                install_tools
            else
                edit_cluster
            fi
            ;;
        3)
            edit_instance_group
            ;;
        4)
            update_cluster
            ;;
        5)
            rolling_update_cluster
            ;;
        6)
            validate_cluster
            ;;
        7)
            export_kubecfg
            ;;
        8)
            addons_menu
            ;;
        0)
            delete_cluster
            ;;
    esac
}

addons_menu() {
    title

	tput cup  7 ${L_PAD} && echo "1. Metrics Server"
	tput cup  8 ${L_PAD} && echo "2. Ingress Nginx"
	tput cup  9 ${L_PAD} && echo "3. Dashboard"
	tput cup 10 ${L_PAD} && echo "4. Heapster (deprecated)"
	tput cup 11 ${L_PAD} && echo "5. Cluster Autoscaler"
	tput cup 12 ${L_PAD} && echo " "
	tput cup 13 ${L_PAD} && echo " "
	tput cup 14 ${L_PAD} && echo " "
    tput cup 15 ${L_PAD} && echo " "
	tput cup 16 ${L_PAD} && echo " "

	# Set bold mode
	tput bold
    tput cup 18 ${L_PAD} && read -p "Enter your choice : " CHOICE
    tput sgr0

	echo_

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
        *)
            cluster_menu
            ;;
    esac
}

create_cluster() {
    title

	tput cup  7 ${L_PAD} && echo "   cloud=aws"
	tput cup  8 ${L_PAD} && echo "   name=${KOPS_CLUSTER_NAME}"
	tput cup  9 ${L_PAD} && echo "   state=s3://${KOPS_STATE_STORE}"
	tput cup 10 ${L_PAD} && echo "   master-size=c4.large"
	tput cup 11 ${L_PAD} && echo "   master-count=1"
	tput cup 12 ${L_PAD} && echo "   master-zones=ap-northeast-2a"
	tput cup 13 ${L_PAD} && echo "1. node-size=${node_size}"
	tput cup 14 ${L_PAD} && echo "2. node-count=${node_count}"
	tput cup 15 ${L_PAD} && echo "   zones=ap-northeast-2a,ap-northeast-2c"
	tput cup 16 ${L_PAD} && echo "   network-cidr=10.10.0.0/16"
	tput cup 17 ${L_PAD} && echo "   networking=calico"

	tput cup 19 ${L_PAD} && echo "0. create"

	# Set bold mode
	tput bold
    tput cup 21 ${L_PAD} && read -p "Enter your choice : " CHOICE
    tput sgr0

	echo_

    case ${CHOICE} in
        1)
            read -p "node_size [${node_size}] : " VAL
            if [ "${VAL}" != "" ]; then
                node_size=${VAL}
            fi
            create_cluster
            ;;
        2)
            read -p "node_count [${node_count}] : " VAL
            if [ "${VAL}" != "" ]; then
                node_count=${VAL}
            fi
            create_cluster
            ;;
        0)
            kops create cluster \
                --cloud=${cloud} \
                --name=${KOPS_CLUSTER_NAME} \
                --state=s3://${KOPS_STATE_STORE} \
                --master-size=${master_size} \
                --master-count=${master_count} \
                --master-zones=${master_zones} \
                --node-size=${node_size} \
                --node-count=${node_count} \
                --zones=${zones} \
                --network-cidr=${network_cidr} \
                --networking=${networking}

            CLUSTER=$(kops get --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} | wc -l)
            read -p "Press Enter to continue..."
            cluster_menu
            ;;
        *)
            cluster_menu
            ;;
    esac
}

read_state_store() {
    # username
    USER=${USER:=$(whoami)}

    if [ "${KOPS_STATE_STORE}" == "" ]; then
        DEFAULT="kops-state-${USER}"
    else
        DEFAULT="${KOPS_STATE_STORE}"
        KOPS_STATE_STORE=
    fi

    # state store
    if [ "${KOPS_STATE_STORE}" == "" ]; then
        read -p "Enter cluster store [${DEFAULT}] : " KOPS_STATE_STORE
    fi
    if [ "${KOPS_STATE_STORE}" == "" ]; then
        KOPS_STATE_STORE="${DEFAULT}"
    fi

    # S3 Bucket
    BUCKET=$(aws s3api get-bucket-acl --bucket ${KOPS_STATE_STORE} | jq '.Owner.ID')
    if [ "${BUCKET}" == "" ]; then
        aws s3 mb s3://${KOPS_STATE_STORE} --region ${REGION}

        BUCKET=$(aws s3api get-bucket-acl --bucket ${KOPS_STATE_STORE} | jq '.Owner.ID')
        if [ "${BUCKET}" == "" ]; then
            clear
            error
        fi
    fi
}

read_cluster_no() {
    CLUSTER_LIST=/tmp/kops-cluster-list
    kops get cluster --state=s3://${KOPS_STATE_STORE} > ${CLUSTER_LIST}

    echo_

    IDX=0
    while read VAR; do
        ARR=(${VAR})

        if [ "${ARR[0]}" == "NAME" ]; then
            NO=""
        else
            IDX=$(( ${IDX} + 1 ))
            NO="${IDX}."
        fi

        printf "%3s\t%s\n" "$NO" "$VAR"
    done < ${CLUSTER_LIST}

    if [ "${IDX}" == "0" ]; then
        read_cluster_name
    else
        printf "\n%3s\t%s\n\n" "0." "new cluster"

        read -p "Enter cluster (0-${IDX})[1] : " CHOICE

        if [ "${CHOICE}" == "" ]; then
            CHOICE="1"
        fi

        if [ "${CHOICE}" == "0" ]; then
            read_cluster_name
        else
            IDX=0
            while read VAR; do
                ARR=(${VAR})

                if [ "${IDX}" == "${CHOICE}" ]; then
                    KOPS_CLUSTER_NAME="${ARR[0]}"
                fi

                IDX=$(( ${IDX} + 1 ))
            done < ${CLUSTER_LIST}
        fi
    fi

    if [ "${KOPS_CLUSTER_NAME}" == "" ]; then
        clear
        error
    fi
}

read_cluster_name() {
    DEFAULT="cluster.k8s.local"
    read -p "Enter your cluster name [${DEFAULT}] : " KOPS_CLUSTER_NAME

    if [ "${KOPS_CLUSTER_NAME}" == "" ]; then
        KOPS_CLUSTER_NAME="${DEFAULT}"
    fi
}

get_cluster() {
    kops get --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    echo_
    read -p "Press Enter to continue..."
    cluster_menu
}

edit_cluster() {
    kops edit cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    echo_
    read -p "Press Enter to continue..."
    cluster_menu
}

edit_instance_group() {
    IG_LIST=/tmp/kops-ig-list

    kops get ig --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} > ${IG_LIST}

    IDX=0
    while read VAR; do
        ARR=(${VAR})

        if [ "${ARR[0]}" == "NAME" ]; then
            NO=""
        else
            IDX=$(( ${IDX} + 1 ))
            NO="${IDX}."
        fi

        printf "%3s\t%s\n" "$NO" "$VAR"
    done < ${IG_LIST}

    echo_
    read -p "Enter your choice : " CHOICE

    IDX=0
    IG_NAME=
    while read VAR; do
        ARR=(${VAR})

        if [ "${IDX}" == "${CHOICE}" ]; then
            IG_NAME="${ARR[0]}"
            break
        fi

        IDX=$(( ${IDX} + 1 ))
    done < ${IG_LIST}

    if [ "${IG_NAME}" != "" ]; then
        kops edit ig ${IG_NAME} --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
        echo_
        read -p "Press Enter to continue..."
    fi

    cluster_menu
}

update_cluster() {
    kops update cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes
    echo_
    read -p "Press Enter to continue..."
    cluster_menu
}

rolling_update_cluster() {
    kops rolling-update cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes
    echo_
    read -p "Press Enter to continue..."
    cluster_menu
}

validate_cluster() {
    kops validate cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    echo_ ""
    kubectl get deploy --all-namespaces
    echo_ ""
    read -p "Press Enter to continue..."
    cluster_menu
}

export_kubecfg() {
    kops export kubecfg --name ${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    echo_
    read -p "Press Enter to continue..."
    cluster_menu
}

delete_cluster() {
    kops delete cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes
    clear
    echo_
    read -p "Press Enter to continue..."
    prepare
}

apply_metrics_server() {
    if [ ! -d /tmp/metrics-server ]; then
        git clone https://github.com/kubernetes-incubator/metrics-server /tmp/metrics-server
    fi

    cd /tmp/metrics-server
    git pull

    echo_ ""
    kubectl apply -f /tmp/metrics-server/deploy/1.8+/
    echo_ ""

    read -p "Press Enter to continue..."
    addons_menu
}

apply_ingress_nginx() {
    ADDON=/tmp/ingress-nginx.yml

    read -p "Enter your ingress domain (ex: *.apps.nalbam.com) : " DOMAIN

    if [ "${DOMAIN}" == "" ]; then
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/ingress-nginx-v1.6.0.yml
    else
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/ingress-nginx-v1.6.0-ssl.yml

        SSL_CERT_ARN=$(aws acm list-certificates | DOMAIN="${DOMAIN}" jq '[.CertificateSummaryList[] | select(.DomainName==env.DOMAIN)][0]' | grep CertificateArn | cut -d'"' -f4)

        if [ "${SSL_CERT_ARN}" == "" ]; then
            error "Empty CertificateArn."
        fi

        echo_ "CertificateArn: ${SSL_CERT_ARN}"

        sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" ${ADDON}
    fi

    echo_ ""
    kubectl apply -f ${ADDON}
    echo_ ""

    if [ "${DOMAIN}" != "" ]; then
        read -p "Enter your root domain (ex: nalbam.com) : " ROOT_DOMAIN

        while [ 1 ]; do
            # ingress-nginx 의 ELB Name 을 획득
            ELB_NAME=$(kubectl get svc -n kube-ingress -o wide | grep ingress-nginx | grep LoadBalancer | awk '{print $4}' | cut -d'-' -f1)

            if [ "${ELB_NAME}" != "" ]; then
                break
            fi

            sleep 1
        done

        # ELB 에서 Hosted Zone ID, DNS Name 을 획득
        ELB_ZONE_ID=$(aws elb describe-load-balancers --load-balancer-name ${ELB_NAME} | grep CanonicalHostedZoneNameID | cut -d'"' -f4)
        ELB_DNS_NAME=$(aws elb describe-load-balancers --load-balancer-name ${ELB_NAME} | grep '"DNSName"' | cut -d'"' -f4)

        # Route53 에서 해당 도메인의 Hosted Zone ID 를 획득
        ZONE_ID=$(aws route53 list-hosted-zones | ROOT_DOMAIN="${ROOT_DOMAIN}." jq '.HostedZones[] | select(.Name==env.ROOT_DOMAIN)' | grep '"Id"' | cut -d'"' -f4 | cut -d'/' -f3)

        # record sets
        RECORD=/tmp/record-sets.json
        curl -so ${RECORD} https://raw.githubusercontent.com/nalbam/kubernetes/master/sample/record-sets.json

        # replace
        sed -i -e "s@{{DOMAIN}}@${DOMAIN}@g" "${RECORD}"
        sed -i -e "s@{{ELB_ZONE_ID}}@${ELB_ZONE_ID}@g" "${RECORD}"
        sed -i -e "s@{{ELB_DNS_NAME}}@${ELB_DNS_NAME}@g" "${RECORD}"

        echo_ ""
        cat ${RECORD}

        # Route53 의 Record Set 에 입력/수정
        aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://${RECORD}
        echo_ ""
    fi

    read -p "Press Enter to continue..."
    addons_menu
}

apply_dashboard() {
    ADDON=/tmp/dashboard.yml

    read -p "Enter your ingress domain (ex: dashboard.apps.nalbam.com) : " DOMAIN

    if [ "${DOMAIN}" == "" ]; then
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/dashboard-v1.8.3.yml
    else
        curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/dashboard-v1.8.3-ing.yml

        sed -i -e "s@dashboard.apps.nalbam.com@${DOMAIN}@g" ${ADDON}
    fi

    echo_ ""
    kubectl apply -f ${ADDON}
    echo_ ""

    read -p "Press Enter to continue..."
    addons_menu
}

apply_heapster() {
    ADDON=/tmp/heapster.yml

    curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/heapster-v1.7.0.yml

    echo_ ""
    kubectl apply -f ${ADDON}
    echo_ ""

    read -p "Press Enter to continue..."
    addons_menu
}

apply_cluster_autoscaler() {
    ADDON=/tmp/cluster_autoscaler.yml

    curl -so ${ADDON} https://raw.githubusercontent.com/nalbam/kubernetes/master/addons/cluster-autoscaler-v1.8.0.yml

    CLOUD_PROVIDER=aws
    IMAGE=k8s.gcr.io/cluster-autoscaler:v1.2.2
    MIN_NODES=2
    MAX_NODES=8
    AWS_REGION=${REGION}
    GROUP_NAME="nodes.${KOPS_CLUSTER_NAME}"
    SSL_CERT_PATH="/etc/ssl/certs/ca-certificates.crt"

    sed -i -e "s@{{CLOUD_PROVIDER}}@${CLOUD_PROVIDER}@g" "${ADDON}"
    sed -i -e "s@{{IMAGE}}@${IMAGE}@g" "${ADDON}"
    sed -i -e "s@{{MIN_NODES}}@${MIN_NODES}@g" "${ADDON}"
    sed -i -e "s@{{MAX_NODES}}@${MAX_NODES}@g" "${ADDON}"
    sed -i -e "s@{{GROUP_NAME}}@${GROUP_NAME}@g" "${ADDON}"
    sed -i -e "s@{{AWS_REGION}}@${AWS_REGION}@g" "${ADDON}"
    sed -i -e "s@{{SSL_CERT_PATH}}@${SSL_CERT_PATH}@g" "${ADDON}"

    echo_ ""
    kubectl apply -f ${ADDON}
    echo_ ""

    read -p "Press Enter to continue..."
    addons_menu
}

clear() {
    KOPS_STATE_STORE=
    KOPS_CLUSTER_NAME=
    rm -rf ~/.kops
}

install_tools() {
    curl -sL toast.sh/helper/bastion.sh | bash
    echo_ ""
    read -p "Press Enter to continue..."
    cluster_menu
}

prepare
