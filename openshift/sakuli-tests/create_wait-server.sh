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
if [ -z $IMAGE_PREFIX ]; then
    IMAGE_PREFIX="${IMAGE_REG}/ta-pipeline-${STAGE}"
fi
if [ -z $BAKERY_BAKERY_URL ]; then
    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
fi
if [ -z $BAKERY_REPORT_URL ]; then
    BAKERY_REPORT_URL="http://bakery-report-server/report/"
fi

IMAGE_NAME='wait-server'
SOURCE_DOCKERFILE='Dockerfile'
SOURCE_DOCKER_CONTEXT_DIR='bakery-app/app-deployment-docker-compose/wait-for-server'
TEMPLATE_BUILD=$FOLDER/openshift.sakuli.image.build.yaml
TEMPLATE_DEPLOY=$FOLDER/openshift.wait.pod.run.template.yaml

echo "ENVS: STAGE=$STAGE, IMAGE_REG=$IMAGE_REG, IMAGE_PREFIX=$IMAGE_PREFIX, IMAGE_NAME=$IMAGE_NAME, SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE, SOURCE_DOCKER_CONTEXT_DIR=$SOURCE_DOCKER_CONTEXT_DIR, BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL, TEMPLATE_BUILD=$TEMPLATE_BUILD, TEMPLATE_DEPLOY=$TEMPLATE_DEPLOY";

count=0


function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc delete pods -l "application=$app_name" --now --force
    echo ".... " && sleep 2
    oc process -f "$TEMPLATE_DEPLOY" \
        -p IMAGE_PREFIX=$IMAGE_PREFIX \
        -p APP_NAME=$app_name \
        -p BAKERY_REPORT_URL=$BAKERY_REPORT_URL \
        -p BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL \
        | oc apply -f -
    
    $FOLDER/validate_pod-state.sh $app_name

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
    echo "Trigger Build for $IMAGE_NAME"
    oc delete builds -l application=$IMAGE_NAME

    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_NAME \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        -p SOURCE_DOCKER_CONTEXT_DIR=$SOURCE_DOCKER_CONTEXT_DIR \
        | oc apply -f -
    oc start-build "$IMAGE_NAME" --follow --wait
    exit $?
}
function buildDeleteOpenshiftObject(){
    echo "Trigger DELETE Build for $IMAGE_NAME"
    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_NAME \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        -p SOURCE_DOCKER_CONTEXT_DIR=$SOURCE_DOCKER_CONTEXT_DIR \
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
SER_NAME=$IMAGE_NAME
triggerOpenshift

wait
exit $?
