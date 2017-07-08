#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $1"
if [[ $1 =~ kill ]]; then
    OS_DELETE_ONLY=true
fi
if [[ $1 =~ update ]]; then
    OS_UPDATE_ONLY=true
fi

TEMPLATE=$FOLDER/openshift.sakuli.image.build.yaml
count=0


function createOpenshiftImageBuild(){
    image_name=$1
    echo "CREATE Image for Sakuli E2E tests"

    oc process -f "$TEMPLATE" -v IMAGE=$image_name | oc create -f -
    echo ".... wait" && sleep 5
    oc get builds -l application=$image_name
}

function deleteOpenshiftImageBuild(){
    image_name=$1
    echo "DELETE Build config for $image_name"

    oc process -f "$TEMPLATE" -v IMAGE=$image_name | oc delete -f -
    echo ".... wait" && sleep 5
}

function triggerUpdateBuild(){
    image_name=$1
    echo "Trigger update Build for $image_name"
    oc start-build $image_name
    echo ".... wait" && sleep 5
    oc get builds -l application=$image_name
}

function deployToOpenshift() {
    echo "--------------------- Build $count ---------------------------------------"
    if [[ $OS_UPDATE_ONLY == "true" ]]; then
        triggerUpdateBuild $1
    else
        deleteOpenshiftImageBuild $1
        if [[ $OS_DELETE_ONLY != "true" ]]; then
            createOpenshiftImageBuild $1
        fi
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}

deployToOpenshift 'sakuli-test-image'

wait
exit $?
