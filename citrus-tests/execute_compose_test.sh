#!/usr/bin/env bash

function checkDefaults(){
    if [ -z $WORKSPACE ]; then
        cd $(dirname $(realpath $0))/..
        export WORKSPACE=$(pwd)
    fi
    if [ -z $COMPOSE_FILE ]; then
        export COMPOSE_FILE="$WORKSPACE/citrus-tests/docker-compose.yml";
    fi
    if [ -z $ADD_ARGUMENT ]; then
        export ADD_ARGUMENT=''
    fi
    echo "WORKSPACE: $WORKSPACE, COMPOSE_FILE: $COMPOSE_FILE, ADD_ARGUMENT: $ADD_ARGUMENT"
}

### start the tests
checkDefaults

docker-compose -f $COMPOSE_FILE kill && docker-compose -f $COMPOSE_FILE rm -f
if [[ $1 =~ kill ]]; then
    exit 0
fi

docker-compose -f $COMPOSE_FILE up --force-recreate --build $@
exit_code=$?
echo "-------------------------------------------------------------------"
echo "exit docker container in docker-compose file '$COMPOSE_FILE'"
echo "EXIT_CODE=$exit_code"
echo "-------------------------------------------------------------------"
exit $exit_code