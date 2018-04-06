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
    TEMPLATE="${SHELL_DIR}/template/localhost.conf"
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
    DOM="$1"
    HOST="$2"
    PORT="$3"

    echo_ "# ${DOM}:${PORT} -> ${HOST}:${PORT}"

    # template
    if [ "${PORT}" == "443" ] || [ "${PORT}" == "8443" ]; then
        TEMPLATE="${SHELL_DIR}/template/vhost-https.conf"
        DEST_FILE="${HTTPD_CONF_DIR}/toast-${DOM}-https.conf"
    else
        TEMPLATE="${SHELL_DIR}/template/vhost-http.conf"
        DEST_FILE="${HTTPD_CONF_DIR}/toast-${DOM}-http.conf"
    fi

    TEMP_FILE1="${TEMP_DIR}/toast-vhost1.tmp"
    TEMP_FILE2="${TEMP_DIR}/toast-vhost2.tmp"
    TEMP_FILE3="${TEMP_DIR}/toast-vhost3.tmp"

    # replace
    sed "s/DOM/$DOM/g" ${TEMPLATE} > ${TEMP_FILE1}
    sed "s/HOST/$HOST/g" ${TEMP_FILE1} > ${TEMP_FILE2}
    sed "s/PORT/$PORT/g" ${TEMP_FILE2} > ${TEMP_FILE3}
    sudo cp -rf ${TEMP_FILE3} ${DEST_FILE}
}

httpd_restart() {
    sudo systemctl restart httpd.service
}

lets_encrypt() {
    DOM="$1"

    if [ -z /etc/letsencrypt/renewal/${DOM}.conf ]; then
        sudo ~/certbot/certbot-auto certonly --standalone --email me@nalbam.com -d ${DOM}
    fi
}

lets_renew() {
    sudo ~/certbot/certbot-auto renew
}

################################################################################

KUBE_ING=/tmp/kube_ing
KUBE_SVC=/tmp/kube_svc

kubectl get ing --all-namespaces -owide | grep " 80 " | awk -F' ' '{print $2 " " $3}' > /tmp/kube_ing
kubectl get svc --all-namespaces -owide | grep 'NodePort' | awk -F' ' '{print $2 " " $4 " " $6}' > /tmp/kube_svc

#md5sum ${KUBE_ING} > ${KUBE_ING}_sum_now
#md5sum ${KUBE_SVC} > ${KUBE_SVC}_sum_now
#
#if [ ! -s ${KUBE_ING}_sum_old ] && [ ! -s ${KUBE_SVC}_sum_old ]; then
#    diff ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old > ${KUBE_ING}_diff
#    diff ${KUBE_SVC}_sum_now ${KUBE_SVC}_sum_old > ${KUBE_SVC}_diff
#
#    if [ -s ${KUBE_ING}_diff ] && [ -s ${KUBE_SVC}_diff ]; then
#        exit
#    fi
#fi

vhost_local

while read ING; do
    # sample-web sample-web.apps.nalbam.com
    ARR=(${ING})

    NAME=${ARR[0]}
    DOMAIN=${ARR[1]}

    if [ "${DOMAIN}" == "" ]; then
        continue
    fi

    while read SVC; do
        # sample-web 10.102.17.19 80:31105/TCP,443:30344/TCP
        ARR=(${SVC})

        if [ "${NAME}" == "${ARR[0]}" ]; then
            IP=${ARR[1]}
            PORTS=($(echo ${ARR[2]} | sed -e "s/,/ /g"))

            for V in "${PORTS[@]}"; do
                PORT=$(echo ${V} | cut -d '/' -f 1 | cut -d ':' -f 1)

                if [ "${PORT}" == "" ]; then
                    continue
                fi

                vhost_http ${DOMAIN} ${IP} ${PORT}
            done

            lets_encrypt ${DOMAIN}

            break
        fi
    done < ${KUBE_SVC}
done < ${KUBE_ING}

httpd_restart

#cp -rf ${KUBE_ING}_sum_now ${KUBE_ING}_sum_old
#cp -rf ${KUBE_SVC}_sum_now ${KUBE_SVC}_sum_old
