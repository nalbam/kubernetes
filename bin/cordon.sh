#!/bin/bash

# k get no --show-labels | cut -d' ' -f1 > /tmp/kube_nodes

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
echo "#"

while read LINE; do
  kubectl cordon ${LINE}
done <${KUBE_NODES}

echo "#"
echo "# $(date)"
