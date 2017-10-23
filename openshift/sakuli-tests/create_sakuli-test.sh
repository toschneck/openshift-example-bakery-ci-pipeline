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

### add additional arguments
if [ -z $STAGE ]; then
    STAGE=dev
fi
if [ -z $IMAGE_REG ]; then
    #consol openshift
    #IMAGE_REG="172.30.19.12:5000"
    #local openshift
    IMAGE_REG="172.30.1.1:5000"
fi
if [ -z $NEXUS_HOST ]; then
    NEXUS_HOST="nexus-ta-nexus.127.0.0.1.nip.io"
fi
if [ -z $IMAGE_PREFIX ]; then
    IMAGE_PREFIX="${IMAGE_REG}/ta-pipeline-${STAGE}"
fi
if [ -z $BAKERY_BAKERY_URL ]; then
    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
fi
if [ -z $BAKERY_REPORT_URL ]; then
    BAKERY_REPORT_URL="http://bakery-report-server/report/"
fi

IMAGE_NAME='sakuli-test-image'
SOURCE_DOCKERFILE='Dockerfile_ubuntu'
TEMPLATE_BUILD=$FOLDER/openshift.sakuli.image.build.yaml
TEMPLATE_DEPLOY=$FOLDER/openshift.sakuli.pod.run.template.yaml

echo "ENVS: STAGE=$STAGE, NEXUS_HOST=$NEXUS_HOST, IMAGE_REG=$IMAGE_REG, IMAGE_PREFIX=$IMAGE_PREFIX, IMAGE_NAME=$IMAGE_NAME, SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL, TEMPLATE_BUILD=$TEMPLATE_BUILD, TEMPLATE_DEPLOY=$TEMPLATE_DEPLOY";

count=0

function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc delete pods -l "application=$app_name"  --grace-period=0
    echo ".... " && sleep 2
    oc process -f "$TEMPLATE_DEPLOY" \
        -p IMAGE_PREFIX=$IMAGE_PREFIX \
        -p NEXUS_HOST=$NEXUS_HOST \
        -p E2E_TEST_NAME=$app_name \
        -p BAKERY_REPORT_URL=$BAKERY_REPORT_URL \
        -p BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL \
        | oc apply -f -
    
    $FOLDER/validate_pod-state.sh $app_name
    exitcode=$?
    echo "-------------------------------------------------------------------"
    exit $exitcode
}

function deleteOpenshiftObject(){
    app_name=$1
    echo "DELETE Config for $app_name"
    oc delete dc -l "application=$app_name"  del--now --force
    oc delete deployment -l "application=$app_name"  --now --force
    oc delete pods -l "application=$app_name"  --now --force
    oc delete service -l "application=$app_name"  --now --force
    oc delete route -l "application=$app_name"  --now --force
    echo "-------------------------------------------------------------------"

}

function buildOpenshiftObject(){
    echo "Trigger Build for $IMAGE_NAME"
    oc delete builds -l application=$IMAGE_NAME

    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_NAME \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        | oc apply -f -
    oc start-build "$IMAGE_NAME" --follow --wait
    exit $?
}
function buildDeleteOpenshiftObject(){
    echo "Trigger DELETE Build for $IMAGE_NAME"
    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_NAME \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        | oc delete -f -
    echo "-------------------------------------------------------------------"
}


function triggerOpenshift() {
    echo "--------------------- APP $count ---------------------------------------"
    if [[ $OS_BUILD_ONLY == "true" ]]; then
        buildOpenshiftObject
    elif [[ $OS_DELETE_DEPLOYMENT == "true" ]]; then
        deleteOpenshiftObject $SER_NAME
        if [[ $OS_DELETE_ALL == "true" ]]; then
            buildDeleteOpenshiftObject
        fi
    else
        deployOpenshiftObject $SER_NAME
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}
SER_NAME=$1
if [[ $OS_DELETE_DEPLOYMENT == "true" ]]; then
    SER_NAME=$2
fi
if [[ $SER_NAME == "" ]]; then
    echo "define var 'SER_NAME'!"
    exit -1
fi

triggerOpenshift

wait
exit $?
