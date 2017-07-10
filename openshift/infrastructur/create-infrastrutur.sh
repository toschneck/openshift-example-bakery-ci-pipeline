#!/usr/bin/env bash

cd $(dirname $(realpath $0))
FOLDER=$(pwd)
echo "ARGS: $1"

if [ -z  $NEXUS_HOST ]; then
    #local openshift
#        IMAGE_PREFIX='172.30.1.1:5000'
#    NEXUS_HOST="nexus-nexus.10.0.100.201.xip.io"
    # consol nexus
    NEXUS_HOST="nexus-nexus.paas.osp.consol.de"
fi

if [ -z $IMAGE_REG ]; then
    #local openshift
#    IMAGE_PREFIX='172.30.1.1:5000'
    #consol openshift
    IMAGE_REG='172.30.19.12:5000'
fi

if [[ $1 =~ delete ]]; then
    echo "============= DELETE INFRASTRUCTUR =================="
    oc process -f $FOLDER/jenkins.yml \
        -v NEXUS_HOST=${NEXUS_HOST} \
        -v IMAGE_REG=${IMAGE_REG} \
        | oc delete -f -
    echo "tried to delete not persistent content"
    if [[ $1 =~ delete-all ]]; then
        oc process -f $FOLDER/jenkins.persistent.yml | oc delete -f -
        echo "tried to delete persistent content"
    fi
    exit 0
fi

echo "============= CREATE INFRASTRUCTUR =================="
echo "NEXUS_HOST=${NEXUS_HOST}"
echo "IMAGE_REG=${IMAGE_REG}"

oc process -f $FOLDER/jenkins.persistent.yml | oc apply -f - \
    && oc process -f $FOLDER/jenkins.yml \
            -v NEXUS_HOST=${NEXUS_HOST} \
            -v IMAGE_REG=${IMAGE_REG} \
            | oc apply -f -
