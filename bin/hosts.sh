#!/bin/bash

SHELL_DIR=$(dirname "$0")

KUBE_ING=/tmp/kube_svc_hosts

NS=
IP=
HOST=
NAME=
PORT=

################################################################################

echo "# $(date)"

kubectl get svc --all-namespaces | awk '{print $1 " " $2 " " $4}' > ${KUBE_ING}

md5sum ${KUBE_ING} > ${KUBE_ING}_sum_now

if [ -f ${KUBE_ING}_sum_old ]; then
    diff ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old > ${KUBE_ING}_diff

    KUBE_ING_SIZE=$(du -k ${KUBE_ING}_diff | cut -f1)

    if [ "${KUBE_ING_SIZE}" == "0" ]; then
        echo "not changed"
        exit
    fi
fi

TMP_HOSTS=/tmp/hosts

cat ${SHELL_DIR}/extra/hosts > ${TMP_HOSTS}
echo "" >> ${TMP_HOSTS}
echo "# $(date)" >> ${TMP_HOSTS}

while read LINE; do
    ARR=(${LINE})

    if [ "${ARR[0]}" == "NAMESPACE" ]; then
        continue
    fi

    echo "${ARR[2]} ${ARR[1]} ${ARR[1]}.local"
    echo "${ARR[2]} ${ARR[1]} ${ARR[1]}.local" >> ${TMP_HOSTS}
done < ${KUBE_ING}

sudo cp -rf ${TMP_HOSTS} /etc/hosts

cp -rf ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old
