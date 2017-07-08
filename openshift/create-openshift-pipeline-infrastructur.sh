#!/usr/bin/env bash
set -e

cd $(dirname `which $0`)
FOLDER=$(pwd)
echo "ARGS: $1"

function checkDefaults(){
    if [ -z $PROJECT_BASENAME ]; then
        export PROJECT_BASENAME='openshift-day'
    fi
}
checkDefaults

if [[ $1 =~ delete ]]; then
    echo "============= DELETE PROJECTS =================="
    oc delete project "${PROJECT_BASENAME}-dev"
    oc delete project "${PROJECT_BASENAME}-qa"
    oc delete project "${PROJECT_BASENAME}-prod"
    exit 0
fi

echo "============= prepare DEV stage =================="
oc new-project "${PROJECT_BASENAME}-dev"

oc create sa cd-agent
oc policy add-role-to-user admin -z cd-agent
echo "SA_TOKEN"
oc serviceaccounts get-token cd-agent

echo "============= prepare QA stage =================="
oc new-project "${PROJECT_BASENAME}-qa"
#oc process -f project/app-secrets.yml -p PROJECT_BASENAME="${PROJECT_BASENAME}" -p BASE_ROUTE_URL="${BASE_ROUTE_URL}" -o yaml | oc apply -f -
oc policy add-role-to-user admin system:serviceaccount:${PROJECT_BASENAME}-dev:cd-agent
oc policy add-role-to-user admin system:serviceaccount:${PROJECT_BASENAME}-dev:jenkins

echo "============= prepare PROD stage =================="
oc new-project "${PROJECT_BASENAME}-prod"
#oc process -f project/app-secrets.yml -p PROJECT_BASENAME="${PROJECT_BASENAME}" -p BASE_ROUTE_URL="${BASE_ROUTE_URL}" -o yaml | oc apply -f -
oc policy add-role-to-user admin system:serviceaccount:${PROJECT_BASENAME}-dev:cd-agent
oc policy add-role-to-user admin system:serviceaccount:${PROJECT_BASENAME}-dev:jenkins

echo "============= configure DEV stage =================="
oc project "${PROJECT_BASENAME}-dev"
oc policy add-role-to-group system:image-puller system:serviceaccounts:${PROJECT_BASENAME}-qa
oc policy add-role-to-group system:image-puller system:serviceaccounts:${PROJECT_BASENAME}-prod

$FOLDER/infrastructur/create-infrastrutur.sh
echo "finished!"
