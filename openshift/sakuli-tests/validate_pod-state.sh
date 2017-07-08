#!/usr/bin/env bash
#set -x
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

echo "ARGS: $1"
IMAGE_NAME='sakuli-test-image'
count=0
maxval=100

SER_NAME='blueberry-pod'
SER_NAME=$1

function validate() {
    state=""
    while  [[ $state != "Terminated" ]] && [ $count -lt $maxval ]; do
        echo "--------------------- Validate $count ---------------------------------------"
        echo ".... " && sleep 2
        state=$(oc describe pod $SER_NAME --show-events=false | grep 'State:' |  awk '{print $2}')
        echo "$SER_NAME state=$state"
        ((count++))
    done;
    echo "-------------------------------------------------------------------"

    exitcode=$(oc describe pod $SER_NAME --show-events=false | grep 'Exit Code:' |  awk '{print $3}')
    echo "EXIT_CODE: $exitcode"
    exit $exitcode

#    pods_template='{{range .items}}{{print .metadata.name " " .metadata.labels.name " " .status.phase}}{{range .status.conditions}}{{if eq .type "Ready"}} {{.status}}{{end}}{{end}}{{println}}{{end}}'

#    oc get pods -l application=$SER_NAME
#    oc get pods -l application=$SER_NAME -o=go-template --template=$pods_template



}

validate

wait
exit $?
