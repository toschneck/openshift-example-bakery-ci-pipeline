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

TEMPLATE=$FOLDER/openshift.sakuli.cron.job.v4.template.yaml
count=0

function createOpenshiftObject(){
    e2e_name=$1
    echo "CREATE JOBSs for $e2e_name"

    # determine different cron expression to execute the jobs in different time windows
    modulo=$((count % 2 ))
    if [[ $modulo == 0 ]] ; then
        CRON_EXPR='0/4 * * * *'
    else
        CRON_EXPR='2/4 * * * *'
    fi
    echo "... schedule Job $count with CRON_EXPR: $CRON_EXPR"
    oc process -f "$TEMPLATE" -v IMAGE_PREFIX=$IMAGE_PREFIX -v CRON_EXPR="$CRON_EXPR" -v E2E_TEST_NAME=$e2e_name | oc create -f -
    oc get scheduledjob -l application=$e2e_name
}

function deleteOpenshiftObject(){
    e2e_name=$1
    echo "DELETE JOB objects for $e2e_name"

    ## oc process -f $TEMPLATE -v IMAGE_PREFIX=$IMAGE_PREFIX -v E2E_TEST_NAME=$e2e_name | oc delete -f -
    oc delete scheduledjob -l application=$e2e_name
    oc delete template -l application=$e2e_name
    oc delete service -l application=$e2e_name
    oc delete routes -l application=$e2e_name
    oc delete job -l application=$e2e_name
    echo ".... wait" && sleep 2
    oc get all -l application=$e2e_name
}

function executeOpenshiftTest() {
    echo "--------------------- JOB $count ---------------------------------------"
    deleteOpenshiftObject $1
    if [[ $OS_DELETE_ONLY != "true" ]]; then
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
