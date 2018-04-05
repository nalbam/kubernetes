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
        sudo cp -rf ${TEMPLATE} "${HTTPD_CONF_DIR}/localhost.conf"
    fi

    # health.html
    if [ -d "${SITE_DIR}/localhost" ]; then
        TEMP_FILE="${TEMP_DIR}/toast-health.tmp"
        echo "OK" > ${TEMP_FILE}
        cp -rf ${TEMP_FILE} "${SITE_DIR}/localhost/index.html"
        cp -rf ${TEMP_FILE} "${SITE_DIR}/localhost/health.html"
    fi
}

vhost_http() {
    DOM="$1"
    HOST="$2"
    PORT="$3"

    echo_ "--> ${DOM}:${PORT}"

    TEMPLATE="${SHELL_DIR}/template/vhost-http.conf"
    TEMP_FILE1="${TEMP_DIR}/toast-vhost1.tmp"
    TEMP_FILE2="${TEMP_DIR}/toast-vhost2.tmp"
    TEMP_FILE3="${TEMP_DIR}/toast-vhost3.tmp"

    # gen vhost
    DEST_FILE="${HTTPD_CONF_DIR}/toast-${DOM}-http.conf"
    sed "s/DOM/$DOM/g" ${TEMPLATE} > ${TEMP_FILE1}
    sed "s/HOST/$HOST/g" ${TEMP_FILE1} > ${TEMP_FILE2}
    sed "s/PORT/$PORT/g" ${TEMP_FILE2} > ${TEMP_FILE3}
    sudo cp -rf ${TEMP_FILE3} ${DEST_FILE}
}

vhost_https() {
    DOM="$1"
    HOST="$2"
    PORT="$3"

    echo_ "--> ${DOM}:${PORT}"

    TEMPLATE="${SHELL_DIR}/template/vhost-https.conf"
    TEMP_FILE1="${TEMP_DIR}/toast-vhost1.tmp"
    TEMP_FILE2="${TEMP_DIR}/toast-vhost2.tmp"
    TEMP_FILE3="${TEMP_DIR}/toast-vhost3.tmp"

    # gen vhost
    DEST_FILE="${HTTPD_CONF_DIR}/toast-${DOM}-https.conf"
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

echo_bar() {
    echo_ "================================================================================"
}

echo_toast() {
    #figlet toast
    echo_bar
    echo_ "  _                  _    "
    echo_ " | |_ ___   __ _ ___| |_  "
    echo_ " | __/ _ \ / _' / __| __| "
    echo_ " | || (_) | (_| \__ \ |_  "
    echo_ "  \__\___/ \__,_|___/\__|  by nalbam "
    echo_bar
}

usage() {
    echo_toast
    echo_ " Usage: toast"
    echo_bar
    echo_
    echo_bar
}

################################################################################

vhost_local

vhost_https kubernetes-dashboard.apps.nalbam.com 10.106.199.73 443

vhost_http  sample-node.apps.nalbam.com 10.106.199.73 80
vhost_https sample-node.apps.nalbam.com 10.106.199.73 443

vhost_http  sample-spring.apps.nalbam.com 10.106.199.73 80
vhost_https sample-spring.apps.nalbam.com 10.106.199.73 443

vhost_http  sample-web.apps.nalbam.com 10.106.199.73 80
vhost_https sample-web.apps.nalbam.com 10.106.199.73 443

httpd_restart
