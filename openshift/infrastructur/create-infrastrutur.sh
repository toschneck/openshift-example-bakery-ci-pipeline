#!/usr/bin/env bash

cd $(dirname $(realpath $0))
FOLDER=$(pwd)
echo "ARGS: $1"

if [ -z  $NEXUS_HOST ]; then
    NEXUS_HOST="nexus-nexus.paas.osp.consol.de"
fi

if [[ $1 =~ delete ]]; then
    echo "============= DELETE INFRASTRUCTUR =================="
    oc process -v NEXUS_HOST=${NEXUS_HOST} -f $FOLDER/jenkins.yml | oc delete -f -
    echo "tried to delete not persistent content"
    if [[ $1 =~ delete-all ]]; then
        oc process -f $FOLDER/jenkins.persistent.yml | oc delete -f -
        echo "tried to delete persistent content"
    fi
    exit 0
fi

echo "============= CREATE INFRASTRUCTUR =================="
echo "NEXUS_HOST=${NEXUS_HOST}"

oc process -f $FOLDER/jenkins.persistent.yml | oc apply -f - \
    && oc process -v NEXUS_HOST=${NEXUS_HOST} -f $FOLDER/jenkins.yml | oc apply -f -
