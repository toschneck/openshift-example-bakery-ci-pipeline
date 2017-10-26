#!/usr/bin/env bash
cd $(dirname $(realpath $0))
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
if [ -z  $NEXUS_HOST ]; then
    NEXUS_HOST="nexus-ta-nexus.127.0.0.1.nip.io"
fi
if [ -z $GIT_BRANCH ]; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi



TEMPLATE_BUILD=$FOLDER/openshift.build.bakery.generic.yaml
TEMPLATE_DEPLOY=$FOLDER/openshift.deploy.web.yaml

BUILD_DOCKERFILE='Dockerfile.report'
PROBE_PATH='/report'
SER_NAME='bakery-report-server'

count=0


function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc process -f "$TEMPLATE_DEPLOY" \
        -p APP_NAME=$app_name \
        -p IMAGE_STREAM=$app_name \
        -p PROBE_PATH=$PROBE_PATH \
        | oc apply -f -
    echo ".... " && sleep 2
    oc get all -l application=$app_name
    echo "-------------------------------------------------------------------"

}

function deleteOpenshiftObject(){
    app_name=$1
    echo "DELETE Config for $app_name"
    oc delete dc -l "application=$app_name"  --now --force
    oc delete deployment -l "application=$app_name"  --now --force
    oc delete pods -l "application=$app_name"  --now --force
    oc delete service -l "application=$app_name"  --now --force
    oc delete route -l "application=$app_name"  --now --force
    echo "-------------------------------------------------------------------"

}

function buildOpenshiftObject(){
    app_name=$1
    echo "Trigger Build for $app_name"
    oc delete builds -l application=$app_name

    oc process -f "$TEMPLATE_BUILD" \
        -p APP_NAME=$app_name \
        -p SOURCE_DOCKERFILE=$BUILD_DOCKERFILE \
        -p SOURCE_REPOSITORY_REF=$GIT_BRANCH \
        -p NEXUS_HOST=$NEXUS_HOST \
        -p UPDATED="$(date +%Y-%m-%d_%H:%M:%S)" \
        | oc apply -f -
    oc start-build "$app_name" --follow --wait
    excode=$?
    echo "EXIT BUILD: $excode"
    exit $excode
}
function buildDeleteOpenshiftObject(){
    app_name=$1
    echo "Trigger DELETE Build for $app_name"
    oc process -f "$TEMPLATE_BUILD" \
        -p APP_NAME=$app_name \
        -p SOURCE_DOCKERFILE=$BUILD_DOCKERFILE \
        | oc delete -f -
    echo "-------------------------------------------------------------------"
}


function triggerOpenshift() {
    echo "--------------------- APP $count ---------------------------------------"
    if [[ $OS_BUILD_ONLY == "true" ]]; then
        buildOpenshiftObject  $SER_NAME
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
