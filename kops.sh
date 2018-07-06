#!/bin/bash

SHELL_DIR=$(dirname $(dirname "$0"))

CUR=0
T_PAD=2
L_PAD=4

CHOICE=
CLUSTER=

REGION=

KOPS_STATE_STORE=
KOPS_CLUSTER_NAME=

ROOT_DOMAIN=
BASE_DOMAIN=

cloud=aws
master_size=c4.large
master_count=1
master_zones=ap-northeast-2a
node_size=m4.large
node_count=2
zones=ap-northeast-2a,ap-northeast-2c
network_cidr=10.10.0.0/16
networking=calico

CONFIG=~/.kops/config
if [ -f ${CONFIG} ]; then
    . ${CONFIG}
fi

success() {
    put_2 "$@"
    exit 0
}

error() {
    put_1 "$@"
    exit 1
}

put_() {
    echo -e "$@"
}

put_1() {
    tput setaf 1
    put_ "$@"
    tput sgr0
}

put_2() {
    tput setaf 2
    put_ "$@"
    tput sgr0
}

put_t() {
	tput cup ${CUR} ${L_PAD}
    tput setaf 3
	tput bold
    put_ "$@"
    tput sgr0
    put_x
}

put_c() {
	tput cup ${CUR} ${L_PAD}
	put_ "$@"
	tput sgr0
    put_x
}

put_q() {
    Q=$1
    if [ "$Q" == "" ]; then
        Q="Enter your choice : "
    fi
    tput cup ${CUR} ${L_PAD}
	tput bold
    read -p "$Q" CHOICE
    tput sgr0
    put_x
}

put_x() {
    CUR=$(( ${CUR} + 1 ))
}

clear() {
    # clear the screen
    tput clear

    CUR=${T_PAD}
}

title() {
    clear

	put_t KOPS UI
    put_x
	put_c "${KOPS_STATE_STORE} > ${KOPS_CLUSTER_NAME}"
	put_x
}

prepare() {
    title

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
            clear_kops_config
            error
        fi
    fi

    REGION=$(aws configure get profile.default.region)

    read_state_store

    read_cluster_no

    save_kops_config

    CLUSTER=$(kops get --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} | wc -l)
    cluster_menu
}

save_kops_config() {
    echo "# kops config" > ${CONFIG}
    echo "KOPS_STATE_STORE=${KOPS_STATE_STORE}" >> ${CONFIG}
    echo "KOPS_CLUSTER_NAME=${KOPS_CLUSTER_NAME}" >> ${CONFIG}
    echo "ROOT_DOMAIN=${ROOT_DOMAIN}" >> ${CONFIG}
    echo "BASE_DOMAIN=${BASE_DOMAIN}" >> ${CONFIG}
}

clear_kops_config() {
    KOPS_CLUSTER_NAME=
    ROOT_DOMAIN=
    BASE_DOMAIN=

    save_kops_config
    . ${CONFIG}
}

cluster_menu() {
    title

    if [ "${CLUSTER}" == "0" ]; then
    	put_c "1. Create Cluster"
        put_c "2. Install Tools"
    else
        put_c "1. Get Cluster"
        put_c "2. Edit Cluster"
        put_c "3. Edit Instance Group"
        put_c "4. Update Cluster"
        put_c "5. Rolling Update Cluster"
        put_c "6. Validate Cluster"
        put_c "7. Export Kubernetes Config"
        put_c "8. Addons"
        put_c "9. Delete Cluster"
    fi

    put_x
    put_q
	put_

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
        9)

            delete_cluster
            ;;
        *)
            cluster_menu
            ;;
    esac
}

addons_menu() {
    title

	put_c "1. Metrics Server"
	put_c "2. Ingress Nginx"
	put_c "3. Dashboard"
	put_c "4. Heapster (deprecated)"
	put_c "5. Cluster Autoscaler"
	put_c "5. Cluster Autoscaler"
	put_x
	put_c "7. Sample Spring App"

    put_x
    put_q
	put_

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
        7)
            apply_sample_spring
            ;;
        *)
            cluster_menu
            ;;
    esac
}

create_cluster() {
    title

	put_c "   cloud=aws"
	put_c "   name=${KOPS_CLUSTER_NAME}"
	put_c "   state=s3://${KOPS_STATE_STORE}"
	put_c "1. master-size=c4.large"
	put_c "   master-count=1"
	put_c "   master-zones=ap-northeast-2a"
	put_c "4. node-size=${node_size}"
	put_c "5. node-count=${node_count}"
	put_c "   zones=ap-northeast-2a,ap-northeast-2c"
	put_c "7. network-cidr=10.10.0.0/16"
	put_c "8. networking=calico"
    put_x
	put_c "0. create"

    put_x
    put_q
	put_

    case ${CHOICE} in
        1)
            read -p "master_size [${master_size}] : " VAL
            if [ "${VAL}" != "" ]; then
                master_size=${VAL}
            fi
            create_cluster
            ;;
        4)
            read -p "node_size [${node_size}] : " VAL
            if [ "${VAL}" != "" ]; then
                node_size=${VAL}
            fi
            create_cluster
            ;;
        5)
            read -p "node_count [${node_count}] : " VAL
            if [ "${VAL}" != "" ]; then
                node_count=${VAL}
            fi
            create_cluster
            ;;
        7)
            read -p "network_cidr [${network_cidr}] : " VAL
            if [ "${VAL}" != "" ]; then
                network_cidr=${VAL}
            fi
            create_cluster
            ;;
        8)
            read -p "networking [${networking}] : " VAL
            if [ "${VAL}" != "" ]; then
                networking=${VAL}
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
        put_
        read -p "Enter cluster store [${DEFAULT}] : " KOPS_STATE_STORE
        put_
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
            clear_kops_config
            error
        fi
    fi
}

read_cluster_no() {
    CLUSTER_LIST=/tmp/kops-cluster-list
    kops get cluster --state=s3://${KOPS_STATE_STORE} > ${CLUSTER_LIST}

    put_

    IDX=0
    while read VAR; do
        ARR=(${VAR})

        if [ "${ARR[0]}" == "NAME" ]; then
            NO=""
        else
            IDX=$(( ${IDX} + 1 ))
            NO="${IDX}."
        fi

        printf "%5s\t%s\n" "$NO" "$VAR"
    done < ${CLUSTER_LIST}

    if [ "${IDX}" == "0" ]; then
        read_cluster_name
    else
        put_
        printf "%5s\t%s\n" "0." "new cluster"

        put_
        read -p "Enter cluster (0-${IDX})[1] : " CHOICE
        put_

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
                    break
                fi

                IDX=$(( ${IDX} + 1 ))
            done < ${CLUSTER_LIST}
        fi
    fi

    if [ "${KOPS_CLUSTER_NAME}" == "" ]; then
        clear_kops_config
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
    put_
    read -p "Press Enter to continue..."
    cluster_menu
}

edit_cluster() {
    kops edit cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    put_
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

    put_
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
        put_
        read -p "Press Enter to continue..."
    fi

    cluster_menu
}

update_cluster() {
    kops update cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes
    put_
    read -p "Press Enter to continue..."
    cluster_menu
}

rolling_update_cluster() {
    kops rolling-update cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes
    put_
    read -p "Press Enter to continue..."
    cluster_menu
}

validate_cluster() {
    kops validate cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    put_
    kubectl get deploy --all-namespaces
    put_
    read -p "Press Enter to continue..."
    cluster_menu
}

export_kubecfg() {
    kops export kubecfg --name ${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    put_
    read -p "Press Enter to continue..."
    cluster_menu
}

delete_cluster() {
    kops delete cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes
    clear_kops_config
    put_
    read -p "Press Enter to continue..."
    prepare
}

apply_metrics_server() {
    if [ ! -d /tmp/metrics-server ]; then
        git clone https://github.com/kubernetes-incubator/metrics-server /tmp/metrics-server
    fi

    cd /tmp/metrics-server
    git pull

    put_
    kubectl apply -f /tmp/metrics-server/deploy/1.8+/
    put_

    read -p "Press Enter to continue..."
    addons_menu
}

get_ingress_elb() {
    ELB_DOMAIN=

    IDX=0
    while [ 1 ]; do
        # ingress-nginx 의 ELB Name 을 획득
        ELB_DOMAIN=$(kubectl get svc -n kube-ingress -o wide | grep ingress-nginx | grep amazonaws | awk '{print $4}')

        if [ "${ELB_DOMAIN}" != "" ]; then
            break
        fi

        IDX=$(( ${IDX} + 1 ))

        if [ "${IDX}" == "20" ]; then
            break
        fi

        sleep 3
    done

    put_ ${ELB_DOMAIN}
}

get_ingress_domain() {
    ELB_IP=

    get_ingress_elb

    IDX=0
    while [ 1 ]; do
        ELB_IP=$(dig +short ${ELB_DOMAIN} | head -n 1)

        if [ "${ELB_IP}" != "" ]; then
            break
        fi

        IDX=$(( ${IDX} + 1 ))

        if [ "${IDX}" == "50" ]; then
            break
        fi

        sleep 3
    done

    if [ "${ELB_IP}" != "" ]; then
        BASE_DOMAIN="apps.${ELB_IP}.nip.io"
    fi

    put_ ${BASE_DOMAIN}
}

get_template() {
    rm -rf ${2}
    if [ -f "${SHELL_DIR}/${1}" ]; then
        cp -rf "${SHELL_DIR}/${1}" ${2}
    else
        curl -s https://raw.githubusercontent.com/nalbam/kubernetes/master/${1} > ${2}
    fi
    if [ ! -f ${2} ]; then
        error "Template does not exists."
    fi
}

apply_ingress_nginx() {
    ADDON=/tmp/ingress-nginx.yml

    read -p "Enter your ingress domain (ex: apps.nalbam.com) : " BASE_DOMAIN

    if [ "${BASE_DOMAIN}" == "" ]; then
        get_template addons/ingress-nginx-v1.6.0.yml ${ADDON}
    else
        get_template addons/ingress-nginx-v1.6.0-ssl.yml ${ADDON}

        SSL_CERT_ARN=$(aws acm list-certificates | DOMAIN="*.${BASE_DOMAIN}" jq '[.CertificateSummaryList[] | select(.DomainName==env.DOMAIN)][0]' | grep CertificateArn | cut -d'"' -f4)

        if [ "${SSL_CERT_ARN}" == "" ]; then
            error "Empty CertificateArn."
        fi

        put_ "CertificateArn: ${SSL_CERT_ARN}"

        sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" ${ADDON}
    fi

    put_
    kubectl apply -f ${ADDON}
    put_
    kubectl get pod,svc -n kube-ingress
    put_

    if [ "${BASE_DOMAIN}" == "" ]; then
        put_ "Pending ELB..."

        get_ingress_domain

        put_
    else
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

        get_template addons/record-sets.json ${RECORD}

        # replace
        sed -i -e "s@{{DOMAIN}}@*.${BASE_DOMAIN}@g" "${RECORD}"
        sed -i -e "s@{{ELB_ZONE_ID}}@${ELB_ZONE_ID}@g" "${RECORD}"
        sed -i -e "s@{{ELB_DNS_NAME}}@${ELB_DNS_NAME}@g" "${RECORD}"

        put_
        cat ${RECORD}

        # Route53 의 Record Set 에 입력/수정
        aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://${RECORD}
        put_
    fi

    save_kops_config

    read -p "Press Enter to continue..."
    addons_menu
}

apply_dashboard() {
    ADDON=/tmp/dashboard.yml

    if [ "${BASE_DOMAIN}" == "" ]; then
        get_ingress_domain
    fi

    if [ "${BASE_DOMAIN}" == "" ]; then
        get_template addons/dashboard-v1.8.3.yml ${ADDON}
    else
        get_template addons/dashboard-v1.8.3-ing.yml ${ADDON}

        DEFAULT="dashboard.${BASE_DOMAIN}"
        read -p "Enter your ingress domain [${DEFAULT}] : " DOMAIN

        if [ "${DOMAIN}" == "" ]; then
            DOMAIN="${DEFAULT}"
        fi

        sed -i -e "s@dashboard.apps.nalbam.com@${DOMAIN}@g" ${ADDON}

        put_ "${DOMAIN}"
    fi

    put_
    kubectl apply -f ${ADDON}
    put_
    kubectl get pod,svc,ing -n kube-system
    put_

    read -p "Press Enter to continue..."
    addons_menu
}

apply_heapster() {
    ADDON=/tmp/heapster.yml

    get_template addons/heapster-v1.7.0.yml ${ADDON}

    put_
    kubectl apply -f ${ADDON}
    put_
    kubectl get pod,svc -n kube-system
    put_

    read -p "Press Enter to continue..."
    addons_menu
}

apply_cluster_autoscaler() {
    ADDON=/tmp/cluster_autoscaler.yml

    get_template addons/cluster-autoscaler-v1.8.0.yml ${ADDON}

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

    put_
    kubectl apply -f ${ADDON}
    put_

    read -p "Press Enter to continue..."
    addons_menu
}

apply_sample_spring() {
    ADDON=/tmp/sample-spring.yml

    if [ "${BASE_DOMAIN}" == "" ]; then
        get_ingress_domain
    fi

    if [ "${BASE_DOMAIN}" == "" ]; then
        get_template sample/sample-spring.yml ${ADDON}
    else
        get_template sample/sample-spring-ing.yml ${ADDON}

        DEFAULT="sample-spring.${BASE_DOMAIN}"
        read -p "Enter your ingress domain [${DEFAULT}] : " DOMAIN

        if [ "${DOMAIN}" == "" ]; then
            DOMAIN="${DEFAULT}"
        fi

        sed -i -e "s@sample-spring.apps.nalbam.com@${DOMAIN}@g" ${ADDON}

        put_ "${DOMAIN}"
    fi

    put_
    kubectl apply -f ${ADDON}
    put_
    kubectl get pod,svc,ing -n default
    put_

    read -p "Press Enter to continue..."
    addons_menu
}

install_tools() {
    curl -sL toast.sh/helper/bastion.sh | bash
    put_
    read -p "Press Enter to continue..."
    cluster_menu
}

prepare
