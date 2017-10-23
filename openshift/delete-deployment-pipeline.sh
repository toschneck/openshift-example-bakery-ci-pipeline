#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $1"
if [[ $1 =~ delete ]]; then
    OS_DELETE_ONLY=true
fi
if [[ $1 =~ build ]]; then
    OS_BUILD_ONLY=true
fi

TEMPLATE=$FOLDER/delete.deployment.pipeline.yml
count=0

STAGE=$1
if [[ $OS_DELETE_DEPLOYMENT == "true" ]] || [[ OS_BUILD_ONLY == "true" ]] ; then
    STAGE=$2
fi
if [[ $STAGE == "" ]]; then
    echo "define var 'STAGE'!"
    exit -1
fi
echo "ENVS: STAGE=$STAGE"

function createOpenshiftObject(){
    app_name=$1
    echo "CREATE Config for $app_name"
    oc process -f "$TEMPLATE" \
        -p APP_NAME=$app_name \
        -p STAGE=$STAGE \
        | oc apply -f -
    oc get all -l application=$app_name
}

function deleteOpenshiftObject(){
    app_name=$1
    echo "DELETE Config for $app_name"
        oc process -f "$TEMPLATE" \
        -p APP_NAME=$app_name \
        -p STAGE=$STAGE \
        | oc delete -f -
    echo ".... wait" && sleep 3
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
        echo "...." && sleep 3
        buildOpenshiftObject $app_name
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}

oc project ta-pipeline-dev
deployToOpenshift "bakery-delete-$STAGE-ci"

wait
exit $?
