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

echo "# $(date) [${COUNT}]"
echo "#"

while read LINE; do
  kubectl cordon ${LINE}
done <${KUBE_NODES}

echo "#"
echo "sleep 3.."
sleep 3

IDX=1
while read LINE; do
  echo "#"
  echo "# ${IDX}/${COUNT} $(date)"
  echo "#"
  echo "# kubectl drain ${LINE}"
  echo "#"

  kubectl drain \
    --delete-emptydir-data \
    --ignore-daemonsets \
    --skip-wait-for-delete-timeout=0 \
    ${LINE}

  # while true; do
  #   CNT=$(kubectl get pod --all-namespaces | grep -v Running | grep -v Completed | grep -v Terminating | wc -l | xargs)
  #   echo ${CNT}
  #   if [ ${CNT} -lt 2 ]; then
  #     break
  #   fi
  #   sleep 3
  # done

  echo "#"
  echo "sleep 5.."
  sleep 5

  IDX=$((${IDX} + 1))
done <${KUBE_NODES}

echo "#"
echo "# $(date)"
