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
if [ -z $GIT_BRANCH ]; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

### DEFAULTS:
IMAGE_SELECTOR='sakuli-test-image'
SOURCE_DOCKERFILE='Dockerfile_ubuntu'
TEMPLATE_BUILD=$FOLDER/openshift.sakuli.image.build.yaml
TEMPLATE_DEPLOY=$FOLDER/openshift.sakuli.pod.run.template.yaml

### add additional arguments
if [ -z $STAGE ]; then
    STAGE=dev
fi
if [ -z $NEXUS_HOST ]; then
    # needed to set via environment vars
    # NEXUS_HOST="nexus-ta-nexus.127.0.0.1.nip.io"
    echo "no env 'NEXUS_HOST' defined" && exit 1
fi
if [ -z $IMAGE_NAME ]; then
    # determine the correct image_name for the k8s objects
    # no longer needed since https://docs.openshift.com/container-platform/3.6/dev_guide/managing_images.html#referencing-images-in-image-streams
    # but currently not enabled on the ConSol cluster
    IMAGE_NAME=$(oc get is -l application=$image_selector -o yaml | grep dockerImageRepository | awk '{print $2}')
fi
if [ -z $BAKERY_BAKERY_URL ]; then
    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
fi
if [ -z $BAKERY_REPORT_URL ]; then
    BAKERY_REPORT_URL="http://bakery-report-server/report/"
fi

echo "ENVS: STAGE=$STAGE, GIT_BRANCH=$GIT_BRANCH, NEXUS_HOST=$NEXUS_HOST, IMAGE_NAME=$IMAGE_NAME, SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE
      BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL, TEMPLATE_BUILD=$TEMPLATE_BUILD,
      TEMPLATE_DEPLOY=$TEMPLATE_DEPLOY";

count=0

function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc delete pods -l "application=$app_name" --now --force
    echo ".... " && sleep 2
    oc process -f "$TEMPLATE_DEPLOY" \
        -p IMAGE_NAME=$IMAGE_NAME \
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
    oc delete dc -l "application=$app_name"  --now --force
    oc delete deployment -l "application=$app_name"  --now --force
    oc delete pods -l "application=$app_name"  --now --force
    oc delete service -l "application=$app_name"  --now --force
    oc delete route -l "application=$app_name"  --now --force
    echo "-------------------------------------------------------------------"

}

function buildOpenshiftObject(){
    echo "Trigger Build for $IMAGE_SELECTOR"
    oc delete builds -l application=$IMAGE_SELECTOR

    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_SELECTOR \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        -p SOURCE_REPOSITORY_REF=$GIT_BRANCH \
        | oc apply -f -
    oc start-build "$IMAGE_NAME" --follow --wait
    exit $?
}
function buildDeleteOpenshiftObject(){
    echo "Trigger DELETE Build for $IMAGE_SELECTOR"
    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_SELECTOR \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        -p SOURCE_REPOSITORY_REF=$GIT_BRANCH \
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
