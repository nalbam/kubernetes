#!/bin/bash

KUBE_NODES=/tmp/kube_nodes

if [ ! -f ${KUBE_NODES} ]; then
  echo "# not found ${KUBE_NODES}"
  exit 1
fi

COUNT=$(cat ${KUBE_NODES} | wc -l | xargs)

if [ "${COUNT}" == "0" ]; then
  echo "# empty ${KUBE_NODES}"
  exit 1
fi

################################################################################

echo "# $(date)"

while read LINE; do

  kubectl cordon ${LINE}

done < ${KUBE_NODES}

while read LINE; do

  echo "# $(date)"

  kubectl drain --delete-local-data --ignore-daemonsets ${LINE}

  while true; do
    COUNT=$(kubectl get pod --all-namespaces | grep -v Running | grep -v Completed | wc -l | xargs)

    if [ ${COUNT} -lt 1 ]; then
      break
    fi

    sleep 2
    printf "."
  done

done < ${KUBE_NODES}

echo "# $(date)"
