#!/usr/bin/env bash
### start local:
#  WORKSPACE=~/sakuli-example-bakery-testing TESTSUITE=order-pdf BROWSER=chrome ./execute_compose_test.sh

function checkDefaults(){
    if [ -z $SERVICENAME ]; then
        export SERVICENAME='sakuli_1'
    fi
    if [ -z $TESTSUITE ]; then
        export TESTSUITE='blueberry'
    fi
    if [ -z $BROWSER ]; then
        export BROWSER='chrome'
    fi
    if [ -z $TESTSUITE_FOLDER ]; then
        export TESTSUITE_FOLDER=/headless/sakuli/bakery/$TESTSUITE
    fi
    if [ -z $TEST_OS ]; then
        export TEST_OS='ubuntu'
    fi
    if [ -z $WORKSPACE ]; then
        cd $(dirname $(realpath $0))/..
        export WORKSPACE=$(pwd)
    fi
    if [ -z $COMPOSE_FILE ]; then
        export COMPOSE_FILE="$WORKSPACE/sakuli-tests/docker-compose.yml";
    fi
    if [ -z $ADD_ARGUMENT ]; then
        export ADD_ARGUMENT=''
    fi
    if [[ $OMD_SERVER == "true" ]]; then
        ### enable the gearman forwarder at sakuli clients
        export ADD_ARGUMENT="$ADD_ARGUMENT -D sakuli.forwarder.gearman.enabled=true"
    fi
    if [ -z $SKIP_COPY_LOGS ]; then
        rm -rf $WORKSPACE/sakuli-tests/**/_logs
    fi
    echo "SERVICENAME: $SERVICENAME, TESTSUITE: $TESTSUITE, TESTSUITE_FOLDER: $TESTSUITE_FOLDER, WORKSPACE: $WORKSPACE, COMPOSE_FILE: $COMPOSE_FILE, ADD_ARGUMENT: $ADD_ARGUMENT"
}

function copyLogs(){
    if [[ $SKIP_COPY_LOGS = true ]]; then echo "skip copy logs" && exit 0; fi
    ## copy the runtime data of the container to the workspace
    CONTAINER_INSTANCE=$1
    LOGFOLDER=$WORKSPACE/_logs/$1_$(date +%s)
    LOGFILE=$LOGFOLDER/_logs/_sakuli.log
    echo "LOGFOLDER: $LOGFOLDER, LOGFILE: $LOGFILE"
    mkdir -p $LOGFOLDER \
        && docker cp $CONTAINER_INSTANCE:$TESTSUITE_FOLDER/_logs $LOGFOLDER \
        && cat $LOGFILE
}

function fixPermissions(){
    var=$WORKSPACE/sakuli-tests
    echo "fix permissions for: $var"
    find "$var"/ -name '*.sh' -exec chmod  a+x {} +
    find "$var"/ -name '*.desktop' -exec chmod  a+x {} +
    chmod -R  a+rw "$var" && find "$var" -type d -exec chmod  a+x {} +
}

### start the sakuli test suite
checkDefaults
#fixPermissions
CONTAINER_NAME=sakuli-test-$TESTSUITE
echo "start docker container: $CONTAINER_NAME"

docker-compose -f $COMPOSE_FILE kill $SERVICENAME  && docker-compose -f $COMPOSE_FILE rm -f  $SERVICENAME
if [[ $1 =~ kill ]]; then
    exit 0
fi
if [[ $1 = '-d' ]]; then
    export SKIP_COPY_LOGS=true
fi

docker-compose -f $COMPOSE_FILE up --exit-code-from $SERVICENAME --force-recreate --build $@ $SERVICENAME
exit_code=$?
copyLogs $CONTAINER_NAME
echo "-------------------------------------------------------------------"
echo "exit docker container '$CONTAINER_NAME' in docker-compose file '$COMPOSE_FILE'"
echo "EXIT_CODE=$exit_code"
echo "-------------------------------------------------------------------"
exit $exit_code