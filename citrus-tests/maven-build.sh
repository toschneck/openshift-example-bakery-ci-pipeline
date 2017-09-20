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
#
if [ -z $OC_CLUSTER_POSTFIX ] ;then
    export OC_CLUSTER_POSTFIX="-ta-pipeline-qa.${NEXUS_HOST#*.}" # postfix after nexus host: works only if nexus is in cluster
#    echo "OC_CLUSTER_POSTFIX not defined!"
#    exit -1
fi
#
echo "............. OC_CLUSTER_POSTFIX=$OC_CLUSTER_POSTFIX"
echo "............. NEXUS_HOST=$NEXUS_HOST"

set -x
#mvn -s $FOLDER/../openshift/infrastructur/maven-cd-settings.xml -f $FOLDER/pom.xml verify
mvn -s $FOLDER/../openshift/infrastructur/maven-cd-settings.xml -f $FOLDER/pom.xml -Dos.cluster.postfix=$OC_CLUSTER_POSTFIX verify
