#!/usr/bin/env bash
cd $(dirname `which $0`)
FOLDER=$(pwd)

echo "ARGS: $1"
if [[ $1 = delete-all ]]; then
    OS_DELETE_ALL=true
fi
if [[ $1 =~ delete ]]; then
    OS_DELETE_DEPLOYMENT=true
fi
if [[ $1 =~ build ]]; then
    OS_BUILD_ONLY=true
fi

TEMPLATE_DEPLOY=$FOLDER/openshift.deploy.activemq.yaml

SER_NAME='activemq'

count=0


function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc process -f "$TEMPLATE_DEPLOY" \
        -v APP_NAME=$app_name \
        | oc apply -f -
    echo ".... " && sleep 2
    oc get all -l application=$app_name
    echo "-------------------------------------------------------------------"

}

function deleteOpenshiftObject(){
    app_name=$1
    echo "DELETE Config for $app_name"
    oc delete dc -l "application=$app_name"  --grace-period=5
    oc delete deployment -l "application=$app_name"  --grace-period=5
    oc delete pods -l "application=$app_name"  --grace-period=5
    oc delete service -l "application=$app_name"  --grace-period=5
    oc delete route -l "application=$app_name"  --grace-period=5
    echo "-------------------------------------------------------------------"

}

function buildDeleteOpenshiftObject(){
    app_name=$1
    echo "Trigger DELETE Build for $app_name"
    oc process -f "$TEMPLATE_DEPLOY" \
        -v APP_NAME=$app_name \
        | oc delete -f -
    echo "-------------------------------------------------------------------"
}


function triggerOpenshift() {
    echo "--------------------- APP $count ---------------------------------------"
    if [[ $OS_BUILD_ONLY == "true" ]]; then
        echo "Use image from Dockerhub => nothing to do"
    elif [[ $OS_DELETE_DEPLOYMENT == "true" ]]; then
        deleteOpenshiftObject $SER_NAME
        if [[ $OS_DELETE_ALL == "true" ]]; then
            buildDeleteOpenshiftObject $SER_NAME
        fi
    else
        deployOpenshiftObject $SER_NAME
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}

triggerOpenshift

wait
exit $?
