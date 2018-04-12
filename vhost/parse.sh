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

vhost_local() {
    # localhost
    TEMPLATE="${SHELL_DIR}/localhost.conf"
    if [ -f "${TEMPLATE}" ]; then
        sudo cp -rf ${TEMPLATE} ${HTTPD_CONF_DIR}/localhost.conf
    fi

    # health.html
    if [ -d "${SITE_DIR}/localhost" ]; then
        TEMP_FILE="${TEMP_DIR}/toast-health.tmp"
        echo "OK" > ${TEMP_FILE}
        cp -rf ${TEMP_FILE} ${SITE_DIR}/localhost/index.html
        cp -rf ${TEMP_FILE} ${SITE_DIR}/localhost/health.html
    fi

    # rm toast-*
    sudo rm -rf ${HTTPD_CONF_DIR}/toast-*
}

vhost_http() {
    _DOM="$1"
    _HOST="$2"
    _PORT="$3"

    echo_ "# ${_DOM}:443 -> ${_HOST}:${_PORT}"

    # template
    TEMPLATE="${SHELL_DIR}/http.conf"
    DEST_FILE="${HTTPD_CONF_DIR}/toast-${_DOM}-http.conf"

    TEMP_FILE1="${TEMP_DIR}/toast-vhost1.tmp"
    TEMP_FILE2="${TEMP_DIR}/toast-vhost2.tmp"
    TEMP_FILE3="${TEMP_DIR}/toast-vhost3.tmp"

    # replace
    sed "s/DOM/$_DOM/g" ${TEMPLATE} > ${TEMP_FILE1}
    sed "s/HOST/$_HOST/g" ${TEMP_FILE1} > ${TEMP_FILE2}
    sed "s/PORT/$_PORT/g" ${TEMP_FILE2} > ${TEMP_FILE3}
    sudo cp -rf ${TEMP_FILE3} ${DEST_FILE}
}

vhost_https() {
    _DOM="$1"
    _HOST="$2"
    _PORT="$3"

    echo_ "# ${_DOM}:443 -> ${_HOST}:${_PORT}"

    # template
    TEMPLATE="${SHELL_DIR}/https.conf"
    DEST_FILE="${HTTPD_CONF_DIR}/toast-${_DOM}-https.conf"

    TEMP_FILE1="${TEMP_DIR}/toast-vhost1.tmp"
    TEMP_FILE2="${TEMP_DIR}/toast-vhost2.tmp"
    TEMP_FILE3="${TEMP_DIR}/toast-vhost3.tmp"

    # replace
    sed "s/DOM/$_DOM/g" ${TEMPLATE} > ${TEMP_FILE1}
    sed "s/HOST/$_HOST/g" ${TEMP_FILE1} > ${TEMP_FILE2}
    sed "s/PORT/$_PORT/g" ${TEMP_FILE2} > ${TEMP_FILE3}
    sudo cp -rf ${TEMP_FILE3} ${DEST_FILE}
}

httpd_restart() {
    sudo systemctl restart httpd.service
}

lets_encrypt() {
    _DOM="$1"

    if [ ! -f /etc/letsencrypt/renewal/${_DOM}.conf ]; then
        sudo ~/certbot/certbot-auto certonly --standalone --email me@nalbam.com -d ${_DOM}
    fi
}

lets_renew() {
    sudo ~/certbot/certbot-auto renew
}

################################################################################

NS=
IP=
HOST=
NAME=
PORT=

date

KUBE_ING=/tmp/kube_ing

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

vhost_local

while read LINE; do
    echo ${LINE}

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

    vhost_http  ${HOST} ${IP} ${PORT}
    vhost_https ${HOST} ${IP} ${PORT}

    lets_encrypt ${HOST}

    NS=
    IP=
    HOST=
    NAME=
    PORT=
done < ${KUBE_ING}

httpd_restart

cp -rf ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old
