#!/bin/bash

echo_() {
    echo -e "$1"
    echo "$1" >> /tmp/toast.log
}

success() {
    echo -e "$(tput setaf 2)$1$(tput sgr0)"
    echo "$1" >> /tmp/toast.log
}

warning() {
    echo -e "$(tput setaf 1)$1$(tput sgr0)"
    echo "$1" >> /tmp/toast.log
}

################################################################################

SHELL_DIR=$(dirname "$0")

HTTPD_CONF_DIR="/etc/httpd/conf.d"

DATA_DIR="/data"
APPS_DIR="${DATA_DIR}/apps"
LOGS_DIR="${DATA_DIR}/logs"
SITE_DIR="${DATA_DIR}/site"
TEMP_DIR="/tmp"

################################################################################

NS=
IP=
HOST=
NAME=
PORT=

date

KUBE_ING=/tmp/kube_ing_hosts

kubectl get ing --all-namespaces -o json \
 | grep -E '"namespace"|"host"|"serviceName"|"servicePort"' \
 | sed 's/[":,]/ /g' \
 | awk -F' ' '{print $1 " " $2}' > ${KUBE_ING}

md5sum ${KUBE_ING} > ${KUBE_ING}_sum_now

if [ -f ${KUBE_ING}_sum_old ]; then
    diff ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old > ${KUBE_ING}_diff

    KUBE_ING_SIZE=$(du -k ${KUBE_ING}_diff | cut -f1)

    if [ "${KUBE_ING_SIZE}" == "0" ]; then
        echo "no change"
        exit
    fi
fi

TMP_HOSTS=/tmp/hosts

cat ${SHELL_DIR}/hosts > ${TMP_HOSTS}

while read LINE; do
    ARR=(${LINE})

    if [ "${ARR[0]}" == "namespace" ]; then
        NS="${ARR[1]}"
        NAME=
        HOST=
        PORT=
        continue
    fi
    if [ "${ARR[0]}" == "host" ]; then
        HOST="${ARR[1]}"
        continue
    fi
    if [ "${ARR[0]}" == "serviceName" ]; then
        NAME="${ARR[1]}"
        continue
    fi
    if [ "${ARR[0]}" == "servicePort" ]; then
        PORT="${ARR[1]}"
    fi

    if [ "${NS}" == "" ] || [ "${HOST}" == "" ] || [ "${NAME}" == "" ] || [ "${PORT}" == "" ]; then
        continue
    fi

    IP=$(kubectl get svc ${NAME} -n ${NS} | grep ${NAME} | awk '{print $3}')

    if [ "${IP}" == "" ]; then
        continue
    fi

    echo "${IP} ${NAME} ${HOST}" >> ${TMP_HOSTS}
done < ${KUBE_ING}

sudo cp -rf ${TMP_HOSTS} /etc/hosts

cp -rf ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old
