#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $1"
if [[ $1 = delete-all ]]; then
    OS_DELETE_ALL=true
fi

if [ -z $NEXUS_HOST ] ;then
    echo "NEXUS_HOST not defined!"
    exit 0
fi
echo "NEXUS_HOST=$NEXUS_HOST"
mvn -B -s openshift/infrastructur/maven-cd-settings.xml -f $FOLDER/../../bakery-app/pom.xml deploy
