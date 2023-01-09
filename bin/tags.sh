#!/bin/bash

CLUSTER_NAME=$1

if [ -z ${CLUSTER_NAME} ]; then
  echo "# not found ${CLUSTER_NAME}"
  exit 1
fi

KUBE_NODES=/tmp/instance-ids

# describe-instances

aws ec2 describe-instances --filters "Name=tag:KubernetesCluster,Values=$CLUSTER_NAME" \
  --query "Reservations[].Instances[].InstanceId" | jq '.[]' -r >${KUBE_NODES}

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
  echo "+ ${LINE}"
  aws ec2 create-tags --resources ${LINE} \
    --tags Key=aws-node-termination-handler/${CLUSTER_NAME},Value=true
done <${KUBE_NODES}

echo "#"
echo "# $(date)"
