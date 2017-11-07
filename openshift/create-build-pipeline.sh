#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $@"
STAGE=$1

if [[ $1 =~ delete ]]; then
    OS_DELETE_ONLY=true
    STAGE=$2
fi
if [[ $1 =~ build ]]; then
    OS_BUILD_ONLY=true
    STAGE=$2
fi
if [[ $STAGE == "" ]]; then
    echo "define var 'STAGE'!"
    exit -1
fi
if [ -z  $NEXUS_HOST ]; then
    #local openshift
    #IMAGE_PREFIX='172.30.1.1:5000'
    export NEXUS_HOST="nexus-ta-nexus.192.168.37.1.nip.io"
    #consol nexus
    #NEXUS_HOST="nexus-ta-nexus.paasint.consol.de"
fi
if [ -z $GIT_BRANCH ]; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

TEMPLATE=$FOLDER/build.pipeline.yml
echo "ENVS: STAGE=$STAGE, GIT_BRANCH=$GIT_BRANCH, NEXUS_HOST=$NEXUS_HOST, TEMPLATE=$TEMPLATE"

count=1

function createOpenshiftObject(){
    app_name=$1
    echo "CREATE Config for $app_name"
    oc process -f "$TEMPLATE" \
        -p APP_NAME=$app_name \
        -p STAGE=$STAGE \
        -p NEXUS_HOST=$NEXUS_HOST \
        -p GIT_BRANCH=$GIT_BRANCH \
        | oc apply -f -
    oc get all -l application=$app_name
}

function deleteOpenshiftObject(){
    app_name=$1
    echo "DELETE Config for $app_name"
        oc process -f "$TEMPLATE" \
        -p APP_NAME=$app_name \
        -p STAGE=$STAGE \
        -p NEXUS_HOST=$NEXUS_HOST \
        | oc delete -f -
    echo ".... wait" && sleep 5
    oc delete pod -l jenkins=slave
}

function buildOpenshiftObject(){
    app_name=$1
    echo "Trigger Build for $app_name"
    oc start-build $app_name --follow --wait
    oc get builds -l application=$app_name
}


function deployToOpenshift() {
    app_name=$1
    echo "--------------------- CREATE $app_name ---------------------------------------"
    if [[ $OS_BUILD_ONLY == "true" ]]; then
        buildOpenshiftObject $app_name
    elif [[ $OS_DELETE_ONLY == "true" ]]; then
        deleteOpenshiftObject $app_name
    else
        createOpenshiftObject $app_name
        echo "...." && sleep 5
        buildOpenshiftObject $app_name
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}

oc project ta-pipeline-dev
deployToOpenshift "bakery-$STAGE-ci"

wait
exit $?
