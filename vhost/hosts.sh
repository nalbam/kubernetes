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

KUBE_ING=/tmp/kube_svc_hosts

kubectl get svc --all-namespaces | awk '{print $1 " " $2 " " $4}' > ${KUBE_ING}

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
echo "" >> ${TMP_HOSTS}
echo "# $(date)" >> ${TMP_HOSTS}

while read LINE; do
    ARR=(${LINE})

    if [ "${ARR[0]}" == "CLUSTER-IP" ]; then
        continue
    fi

    echo "${ARR[2]} ${ARR[1]} ${ARR[0]}.${ARR[1]} ${ARR[0]}.${ARR[1]}.local"
    echo "${ARR[2]} ${ARR[1]} ${ARR[0]}.${ARR[1]} ${ARR[0]}.${ARR[1]}.local" >> ${TMP_HOSTS}
done < ${KUBE_ING}

sudo cp -rf ${TMP_HOSTS} /etc/hosts

cp -rf ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old
