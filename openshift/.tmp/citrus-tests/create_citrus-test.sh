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
#if [ -z $STAGE ]; then
#    STAGE=dev
#fi
#if [ -z $IMAGE_REG ]; then
#    #consol openshift
#    #IMAGE_REG="172.30.19.12:5000"
#    #local openshift
#    IMAGE_REG="172.30.1.1:5000"
#fi
#if [ -z $NEXUS_HOST ]; then
#    NEXUS_HOST="nexus-nexus.paas.osp.consol.de"
#fi
#if [ -z $IMAGE_PREFIX ]; then
#    IMAGE_PREFIX="${IMAGE_REG}/openshift-day-${STAGE}"
#fi
#if [ -z $BAKERY_BAKERY_URL ]; then
#    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
#fi
#if [ -z $BAKERY_REPORT_URL ]; then
#    BAKERY_REPORT_URL="http://bakery-report-server/report/"
#fi

TEMPLATE_DEPLOY=$FOLDER/citrus-test.yml

#echo "ENVS: STAGE=$STAGE, NEXUS_HOST=$NEXUS_HOST, IMAGE_REG=$IMAGE_REG, IMAGE_PREFIX=$IMAGE_PREFIX, IMAGE_NAME=$IMAGE_NAME, SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL, TEMPLATE_BUILD=$TEMPLATE_BUILD, TEMPLATE_DEPLOY=$TEMPLATE_DEPLOY";

count=0

function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc delete pods -l "application=$app_name"  --grace-period=0
    echo ".... " && sleep 2
    oc process -f "$TEMPLATE_DEPLOY" \
        -v CITRUS_TEST_NAME=$app_name \
        | oc apply -f -
#        -v BAKERY_REPORT_URL=$BAKERY_REPORT_URL \
#        -v BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL \

    $FOLDER/../sakuli-tests/validate_pod-state.sh $app_name
    exitcode=$?
    echo "-------------------------------------------------------------------"
    exit $exitcode
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


function triggerOpenshift() {
    echo "--------------------- APP $count ---------------------------------------"
    if [[ $OS_DELETE_DEPLOYMENT == "true" ]]; then
        deleteOpenshiftObject $SER_NAME
    else
        deployOpenshiftObject $SER_NAME
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}
SER_NAME=citrus-test
triggerOpenshift

wait
exit $?
