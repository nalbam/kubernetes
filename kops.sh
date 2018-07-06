#!/bin/bash

SHELL_DIR=$(dirname "$0")

L_PAD="$(printf %3s)"

ANSWER=
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

put_() {
    echo -e "${L_PAD}$@"
}

put_e() {
    echo
    echo -e "${L_PAD}$(tput setaf 1)$@$(tput sgr0)"
    echo
    exit 1
}

put_t() {
    echo
    echo
    echo -e "${L_PAD}$(tput setaf 3)$(tput bold)$@$(tput sgr0)"
    echo
}

put_q() {
    Q=$1
    if [ "$Q" == "" ]; then
        Q="Enter your choice : "
    fi

    read -p "${L_PAD}$(tput setaf 2)$Q$(tput sgr0)" ANSWER
}

put_w() {
    echo
    read -p "${L_PAD}$(tput setaf 4)Press Enter to continue...$(tput sgr0)"
    echo
}

title() {
    # clear the screen
    tput clear

	put_t KOPS UI
    echo
	put_ "${KOPS_STATE_STORE} > ${KOPS_CLUSTER_NAME}"
	echo
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
            put_e
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
    	put_ "1. Create Cluster"
        put_ "2. Install Tools"
    else
        put_ "1. Get Cluster"
        put_ "2. Edit Cluster"
        put_ "3. Update Cluster"
        put_ "4. Rolling Update Cluster"
        put_ "5. Validate Cluster"
        put_ "6. Export Kubernetes Config"
        put_ "7. Addons"
        echo
        put_ "9. Delete Cluster"
    fi

    echo
    put_q
	echo

    case ${ANSWER} in
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
            update_cluster
            ;;
        4)
            rolling_update_cluster
            ;;
        5)
            validate_cluster
            ;;
        6)
            export_kubecfg
            ;;
        7)
            addons_menu
            ;;
        9)
            put_q "Are you sure? (YES/[no]) : "
            echo

            if [ "${ANSWER}" == "YES" ]; then
                delete_cluster
            else
                cluster_menu
            fi
            ;;
        *)
            cluster_menu
            ;;
    esac
}

addons_menu() {
    title

	put_ "1. Metrics Server"
	put_ "2. Ingress Nginx"
	put_ "3. Dashboard"
	put_ "4. Heapster (deprecated)"
	put_ "5. Cluster Autoscaler"
	echo
	put_ "7. Sample Spring App"

    echo
    put_q
	echo

    case ${ANSWER} in
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

	put_ "   cloud=${cloud}"
	put_ "   name=${KOPS_CLUSTER_NAME}"
	put_ "   state=s3://${KOPS_STATE_STORE}"
	put_ "1. master-size=${master_size}"
	put_ "   master-count=${master_count}"
	put_ "   master-zones=${master_zones}"
	put_ "4. node-size=${node_size}"
	put_ "5. node-count=${node_count}"
	put_ "   zones=${zones}"
	put_ "7. network-cidr=${network_cidr}"
	put_ "8. networking=${networking}"
    echo
	put_ "0. create"

    echo
    put_q
	echo

    case ${ANSWER} in
        1)
            put_q "Enter master size [${master_size}] : "
            if [ "${ANSWER}" != "" ]; then
                master_size=${ANSWER}
            fi
            create_cluster
            ;;
        4)
            put_q "Enter node size [${node_size}] : "
            if [ "${ANSWER}" != "" ]; then
                node_size=${ANSWER}
            fi
            create_cluster
            ;;
        5)
            put_q "Enter node count [${node_count}] : "
            if [ "${ANSWER}" != "" ]; then
                node_count=${ANSWER}
            fi
            create_cluster
            ;;
        7)
            put_q "Enter network cidr [${network_cidr}] : "
            if [ "${ANSWER}" != "" ]; then
                network_cidr=${ANSWER}
            fi
            create_cluster
            ;;
        8)
            put_q "Enter networking [${networking}] : "
            if [ "${ANSWER}" != "" ]; then
                networking=${ANSWER}
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

            put_w

            CLUSTER=$(kops get --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} | wc -l)
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
    fi

    KOPS_STATE_STORE=

    echo
    put_q "Enter cluster store [${DEFAULT}] : "
    echo

    if [ "${ANSWER}" == "" ]; then
        KOPS_STATE_STORE="${DEFAULT}"
    else
        KOPS_STATE_STORE="${ANSWER}"
    fi

    # S3 Bucket
    BUCKET=$(aws s3api get-bucket-acl --bucket ${KOPS_STATE_STORE} | jq '.Owner.ID')
    if [ "${BUCKET}" == "" ]; then
        aws s3 mb s3://${KOPS_STATE_STORE} --region ${REGION}

        BUCKET=$(aws s3api get-bucket-acl --bucket ${KOPS_STATE_STORE} | jq '.Owner.ID')
        if [ "${BUCKET}" == "" ]; then
            KOPS_STATE_STORE=
            clear_kops_config
            put_e
        fi
    fi
}

read_cluster_no() {
    CLUSTER_LIST=/tmp/kops-cluster-list
    kops get cluster --state=s3://${KOPS_STATE_STORE} > ${CLUSTER_LIST}

    IDX=0
    while read VAR; do
        ARR=(${VAR})

        if [ "${ARR[0]}" == "NAME" ]; then
            continue
        fi

        IDX=$(( ${IDX} + 1 ))

        put_ "${IDX}. ${ARR[0]}"
    done < ${CLUSTER_LIST}

    if [ "${IDX}" == "0" ]; then
        read_cluster_name
    else
        echo
        put_ "0. new"

        echo
        put_q "Enter cluster (0-${IDX})[1] : "
        echo

        if [ "${ANSWER}" == "" ]; then
            ANSWER="1"
        fi

        if [ "${ANSWER}" == "0" ]; then
            read_cluster_name
        else
            IDX=0
            while read VAR; do
                ARR=(${VAR})

                if [ "${IDX}" == "${ANSWER}" ]; then
                    KOPS_CLUSTER_NAME="${ARR[0]}"
                    break
                fi

                IDX=$(( ${IDX} + 1 ))
            done < ${CLUSTER_LIST}
        fi
    fi

    if [ "${KOPS_CLUSTER_NAME}" == "" ]; then
        clear_kops_config
        put_e
    fi
}

read_cluster_name() {
    DEFAULT="cluster.k8s.local"

    echo
    put_q "Enter your cluster name [${DEFAULT}] : "
    echo

    if [ "${ANSWER}" == "" ]; then
        KOPS_CLUSTER_NAME="${DEFAULT}"
    else
        KOPS_CLUSTER_NAME="${ANSWER}"
    fi
}

get_cluster() {
    kops get --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}

    put_w

    cluster_menu
}

edit_cluster() {
    IG_LIST=/tmp/kops-ig-list

    kops get ig --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} > ${IG_LIST}

    IDX=0
    while read VAR; do
        ARR=(${VAR})

        if [ "${ARR[0]}" == "NAME" ]; then
            continue
        fi

        IDX=$(( ${IDX} + 1 ))

        put_ "${IDX}. ${ARR[0]}"
    done < ${IG_LIST}

    echo
    put_ "0. cluster"

    echo
    put_q
    echo

    SELECTED=

    if [ "${ANSWER}" == "0" ]; then
        SELECTED="cluster"

        kops edit ${SELECTED} --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    else
        IDX=0
        while read VAR; do
            ARR=(${VAR})

            if [ "${IDX}" == "${ANSWER}" ]; then
                SELECTED="${ARR[0]}"
                break
            fi

            IDX=$(( ${IDX} + 1 ))
        done < ${IG_LIST}

        if [ "${SELECTED}" != "" ]; then
            kops edit ig ${SELECTED} --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
        fi
    fi

    if [ "${SELECTED}" != "" ]; then
        put_w
    fi

    cluster_menu
}

update_cluster() {
    kops update cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes

    put_w
    cluster_menu
}

rolling_update_cluster() {
    kops rolling-update cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes

    put_w
    cluster_menu
}

validate_cluster() {
    kops validate cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}
    echo
    kubectl get deploy --all-namespaces

    put_w
    cluster_menu
}

export_kubecfg() {
    kops export kubecfg --name ${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE}

    put_w
    cluster_menu
}

delete_cluster() {
    kops delete cluster --name=${KOPS_CLUSTER_NAME} --state=s3://${KOPS_STATE_STORE} --yes

    clear_kops_config

    put_w
    prepare
}

apply_metrics_server() {
    if [ ! -d /tmp/metrics-server ]; then
        git clone https://github.com/kubernetes-incubator/metrics-server /tmp/metrics-server
    fi

    cd /tmp/metrics-server
    git pull

    echo
    kubectl apply -f /tmp/metrics-server/deploy/1.8+/

    put_w
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
        put_e "Template does not exists."
    fi
}

apply_ingress_nginx() {
    ADDON=/tmp/ingress-nginx.yml

    put_q "Enter your ingress domain (ex: apps.nalbam.com) : "
    echo

    BASE_DOMAIN="${ANSWER}"

    if [ "${BASE_DOMAIN}" == "" ]; then
        get_template addons/ingress-nginx-v1.6.0.yml ${ADDON}
    else
        get_template addons/ingress-nginx-v1.6.0-ssl.yml ${ADDON}

        SSL_CERT_ARN=$(aws acm list-certificates | DOMAIN="*.${BASE_DOMAIN}" jq '[.CertificateSummaryList[] | select(.DomainName==env.DOMAIN)][0]' | grep CertificateArn | cut -d'"' -f4)

        if [ "${SSL_CERT_ARN}" == "" ]; then
            put_e "Empty CertificateArn."
        fi

        put_ "CertificateArn: ${SSL_CERT_ARN}"

        sed -i -e "s@{{SSL_CERT_ARN}}@${SSL_CERT_ARN}@g" ${ADDON}
    fi

    echo
    kubectl apply -f ${ADDON}
    echo
    kubectl get pod,svc -n kube-ingress
    echo

    if [ "${BASE_DOMAIN}" == "" ]; then
        put_ "Pending ELB..."

        get_ingress_domain
    else
        put_q "Enter your root domain (ex: nalbam.com) : "
        echo

        ROOT_DOMAIN="${ANSWER}"

        if [ "${ROOT_DOMAIN}" == "" ]; then
            put_e "Empty Root Domain."
        fi

        while [ 1 ]; do
            # ingress-nginx 의 ELB Name 을 획득
            ELB_NAME=$(kubectl get svc -n kube-ingress -o wide | grep ingress-nginx | grep LoadBalancer | awk '{print $4}' | cut -d'-' -f1)

            if [ "${ELB_NAME}" != "" ]; then
                break
            fi

            sleep 3
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

        cat ${RECORD}

        # Route53 의 Record Set 에 입력/수정
        aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://${RECORD}
    fi

    save_kops_config

    put_w
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
        put_q "Enter your dashboard domain [${DEFAULT}] : "
        echo

        DOMAIN="${ANSWER}"

        if [ "${DOMAIN}" == "" ]; then
            DOMAIN="${DEFAULT}"
        fi

        sed -i -e "s@dashboard.apps.nalbam.com@${DOMAIN}@g" ${ADDON}

        put_ "${DOMAIN}"
    fi

    echo
    kubectl apply -f ${ADDON}
    echo
    kubectl get pod,svc,ing -n kube-system

    put_w
    addons_menu
}

apply_heapster() {
    ADDON=/tmp/heapster.yml

    get_template addons/heapster-v1.7.0.yml ${ADDON}

    echo
    kubectl apply -f ${ADDON}
    echo
    kubectl get pod,svc -n kube-system

    put_w
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

    echo
    kubectl apply -f ${ADDON}

    put_w
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
        put_q "Enter your sample-spring domain [${DEFAULT}] : "
        echo

        DOMAIN="${ANSWER}"

        if [ "${DOMAIN}" == "" ]; then
            DOMAIN="${DEFAULT}"
        fi

        sed -i -e "s@sample-spring.apps.nalbam.com@${DOMAIN}@g" ${ADDON}

        put_ "${DOMAIN}"
    fi

    echo
    kubectl apply -f ${ADDON}
    echo
    kubectl get pod,svc,ing -n default

    put_w
    addons_menu
}

install_tools() {
    curl -sL toast.sh/helper/bastion.sh | bash

    put_w
    cluster_menu
}

prepare
