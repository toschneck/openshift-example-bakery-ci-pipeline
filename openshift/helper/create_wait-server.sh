#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $1"
if [[ $1 =~ delete ]]; then
    OS_DELETE_DEPLOYMENT=true
fi

### DEFAULTS:
SER_NAME='wait-server'
TEMPLATE_DEPLOY=$FOLDER/openshift.wait.pod.run.template.yaml
if [ -z $BAKERY_BAKERY_URL ]; then
    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
fi
if [ -z $BAKERY_REPORT_URL ]; then
    BAKERY_REPORT_URL="http://bakery-report-server/report/"
fi

echo "ENVS: BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL, TEMPLATE_DEPLOY=$TEMPLATE_DEPLOY";

count=0


function deployOpenshiftObject(){
    app_name=$1
    echo "CREATE DEPLOYMENT for $app_name"
    oc delete pods -l "application=$app_name" --now --force
    echo ".... " && sleep 2
    oc process -f "$TEMPLATE_DEPLOY" \
        -p APP_NAME=$app_name \
        -p BAKERY_REPORT_URL=$BAKERY_REPORT_URL \
        -p BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL \
        | oc apply -f -
    
    $FOLDER/../helper/validate_pod-state.sh $app_name

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
triggerOpenshift

wait
exit $?
