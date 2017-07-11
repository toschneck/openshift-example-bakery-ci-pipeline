#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $1"
if [[ $1 = delete-all ]]; then
    OS_DELETE_ALL=true
fi

export NEXUS_HOST=${NEXUS_HOST:-$1}
if [ -z $NEXUS_HOST ] ;then
    echo "NEXUS_HOST not defined!"
    exit -1
fi
echo "............. NEXUS_HOST=$NEXUS_HOST"

echo "mvn -s $FOLDER/../openshift/infrastructur/maven-cd-settings.xml -f $FOLDER/pom.xml -Dos.cluster.postfix=-openshift-day-qa.paas.osp.consol.de verify"
mvn -s $FOLDER/../openshift/infrastructur/maven-cd-settings.xml -f $FOLDER/pom.xml -Dos.cluster.postfix=-openshift-day-qa.paas.osp.consol.de verify
