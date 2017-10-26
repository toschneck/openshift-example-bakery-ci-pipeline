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

### DEFAULTS:
IMAGE_SELECTOR='wait-server'
SOURCE_DOCKERFILE='Dockerfile'
SOURCE_DOCKER_CONTEXT_DIR='bakery-app/app-deployment-docker-compose/wait-for-server'
TEMPLATE_BUILD=$FOLDER/openshift.sakuli.image.build.yaml
TEMPLATE_DEPLOY=$FOLDER/openshift.wait.pod.run.template.yaml
### add additional arguments
if [ -z $STAGE ]; then
    STAGE=dev
fi
if [ -z $IMAGE_NAME ]; then
    # determine the correct image_name for the k8s objects
    # no longer needed since https://docs.openshift.com/container-platform/3.6/dev_guide/managing_images.html#referencing-images-in-image-streams
    # but currently not enabled on the ConSol cluster
    IMAGE_NAME=$(oc get is -l application=$IMAGE_SELECTOR -o yaml | grep dockerImageRepository | awk '{print $2}')
fi
if [ -z $BAKERY_BAKERY_URL ]; then
    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
fi
if [ -z $BAKERY_REPORT_URL ]; then
    BAKERY_REPORT_URL="http://bakery-report-server/report/"
fi

echo "ENVS: STAGE=$STAGE, IMAGE_NAME=$IMAGE_NAME, SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE, SOURCE_DOCKER_CONTEXT_DIR=$SOURCE_DOCKER_CONTEXT_DIR, BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL, TEMPLATE_BUILD=$TEMPLATE_BUILD, TEMPLATE_DEPLOY=$TEMPLATE_DEPLOY";

count=0


function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc delete pods -l "application=$app_name" --now --force
    echo ".... " && sleep 2
    oc process -f "$TEMPLATE_DEPLOY" \
        -p IMAGE_NAME=$IMAGE_NAME \
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
    echo "Trigger Build for $IMAGE_SELECTOR"
    oc delete builds -l application=$IMAGE_SELECTOR

    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_SELECTOR \
        -p SOURCE_DOCKERFILE=$SOURCE_DOCKERFILE \
        -p SOURCE_DOCKER_CONTEXT_DIR=$SOURCE_DOCKER_CONTEXT_DIR \
        | oc apply -f -
#    oc start-build "$IMAGE_SELECTOR" --follow --wait
    tempfixBuild $IMAGE_SELECTOR
    excode=$?
    echo "EXIT BUILD: $excode"
    exit $excode
}

# needed as long bug is not fixed: https://github.com/openshift/origin/issues/17019
function tempfixBuild(){
    app_name=$1
    echo "+oc start-build "$app_name" --follow --wait > logs.$app_name.txt"
    oc start-build "$app_name" --follow --wait > logs.$app_name.txt
    excode=$?
    echo "EXIT BUILD: $excode"
    cat logs.$app_name.txt
    if [[ $excode == 1 ]] ; then
       cat logs.$app_name.txt | grep -i "Push successful" && echo "change exitcode to 0" && return 0
    fi
    return $excode
}

function buildDeleteOpenshiftObject(){
    echo "Trigger DELETE Build for $IMAGE_SELECTOR"
    oc process -f "$TEMPLATE_BUILD" \
        -p IMAGE=$IMAGE_SELECTOR \
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
SER_NAME=$IMAGE_SELECTOR
triggerOpenshift

wait
exit $?
