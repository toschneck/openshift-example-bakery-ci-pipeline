#!/usr/bin/env bash

function checkDefaults(){
    if [ -z $WORKSPACE ]; then
        cd $(dirname $(realpath $0))/..
        export WORKSPACE=$(pwd)
    fi
    echo "WORKSPACE: $WORKSPACE"
}

### cleanup old stuff
checkDefaults
COMPOSEFILE="$WORKSPACE/omd-nagios/docker-compose.yml"

if [[ $1 =~ restart ]]; then
    docker-compose -f $COMPOSEFILE up -d
    exit 0
fi
if [[ $1 =~ stop ]]; then
    docker-compose -f $COMPOSEFILE stop
    exit 0
fi

docker-compose -f $COMPOSEFILE kill || echo "kill running containers"
if [[ $1 =~ kill ]]; then
    exit 0
fi

### build an startup application and  start the wait container to block until the web-applications are reachable
docker-compose -f $COMPOSEFILE up --force-recreate --build -d \
    && exit 0

echo "unexpected error starting OMD-Nagios containers from '$COMPOSEFILE'"
exit -1