#!/bin/bash

REGIONS=/tmp/regions
INSTANCES=/tmp/instances

aws ec2 describe-regions | grep RegionName | awk -F'"' '{print $4}' > ${REGIONS}

while read REGION; do
    echo ">> region : ${REGION}"

    aws configure set default.region ${REGION}

    aws ec2 describe-instances | grep InstanceId | awk -F'"' '{print $4}' > ${INSTANCES}

    while read ID; do
        aws ec2 modify-instance-attribute --instance-id ${ID} --no-disable-api-termination
        aws ec2 terminate-instances --instance-ids ${ID} | grep InstanceId
    done < ${INSTANCES}

    aws ec2 describe-instances | grep InstanceId | awk -F'"' '{print $4}'
done < ${REGIONS}

echo "# done."
