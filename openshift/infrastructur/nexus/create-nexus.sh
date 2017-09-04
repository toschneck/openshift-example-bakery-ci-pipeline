#!/usr/bin/env bash

cd $(dirname $(realpath $0))
FOLDER=$(pwd)
echo "ARGS: $1"

echo "============= USE PROJECT NEXUS =================="
oc project ta-nexus
if [[ $1 =~ delete ]]; then
    echo "============= DELETE NEXUS =================="
    oc process -f $FOLDER/nexus2-persistent-template.yaml | oc delete -f -
    exit $?
fi

echo "============= CREATE NEXUS =================="
oc process -f $FOLDER/nexus2-persistent-template.yaml | oc apply -f -
#    && oc process -f $FOLDER/nexus.yml | oc apply -f -
