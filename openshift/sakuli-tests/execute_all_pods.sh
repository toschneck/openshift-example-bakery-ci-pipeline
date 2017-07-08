#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

### add additional arguments
if [ -z $IMAGE_PREFIX ]; then
    #local openshift
#    IMAGE_PREFIX='172.30.1.1:5000/omd-mon'
    #consol openshift
    IMAGE_PREFIX='172.30.19.12:5000/omd-mon'
fi

echo "ARGS: $1"
if [[ $1 =~ kill ]]; then
    OS_DELETE_ONLY=true
fi

TEMPLATE=$FOLDER/openshift.sakuli.pod.run.template.yaml
count=0

function createOpenshiftObject(){
    e2e_name=$1
    echo "CREATE POD for $e2e_name"
    oc process -f "$TEMPLATE" -v IMAGE_PREFIX=$IMAGE_PREFIX -v E2E_TEST_NAME=$e2e_name | oc apply -f -
    oc get pod -l application=$e2e_name
}

function deleteOpenshiftObject(){
    e2e_name=$1
    echo "DELETE POD for $e2e_name"

    ## oc process -f $TEMPLATE -v IMAGE_PREFIX=$IMAGE_PREFIX -v E2E_TEST_NAME=$e2e_name | oc delete -f -
    oc delete template -l application=$e2e_name
    oc delete service -l application=$e2e_name
    oc delete routes -l application=$e2e_name
    oc delete pod -l application=$e2e_name
    echo ".... wait" && sleep 2
    oc get all -l application=$e2e_name
}

function executeOpenshiftTest() {
    echo "--------------------- POD $count ---------------------------------------"
    if [[ $OS_DELETE_ONLY == "true" ]]; then
        deleteOpenshiftObject $1
    else
        createOpenshiftObject $1
    fi
    echo "-------------------------------------------------------------------"
    ((count++))

}

### excute the different services
# Example Sakuli Testsuite
executeOpenshiftTest 'check-links'

# Creates a PA Ticket in Stage Environment
executeOpenshiftTest 'check-new-ticket'

# Creates Ticket and walks through PA process
executeOpenshiftTest 'check-walk-pa'

# Continue with an existing Ticket
executeOpenshiftTest 'check-continue-ticket'

# create ticket with portal
executeOpenshiftTest 'check-portal'
wait
exit $?
