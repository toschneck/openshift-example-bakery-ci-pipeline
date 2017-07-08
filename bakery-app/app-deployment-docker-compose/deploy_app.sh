#!/usr/bin/env bash

function checkDefaults(){
    if [ -z $WORKSPACE ]; then
        cd $(dirname $(realpath $0))/../..
        export WORKSPACE=$(pwd)
    fi
    echo "WORKSPACE: $WORKSPACE"
}

### cleanup old stuff
checkDefaults
COMPOSEFILE="$WORKSPACE/bakery-app/app-deployment-docker-compose/docker-compose.yml"
COMPOSE_WAIT="$WORKSPACE/bakery-app/app-deployment-docker-compose/docker-compose-wait-container.yml"

docker-compose -f $COMPOSEFILE kill || echo "kill running containers"
docker-compose -f $COMPOSE_WAIT kill || echo "kill running containers"
docker-compose -f $COMPOSEFILE rm -f || echo "delete stoped containers"
docker-compose -f $COMPOSE_WAIT rm -f || echo "delete stoped containers"

if [[ $1 =~ kill ]]; then
    exit 0
fi
### build an startup application and  start the wait container to block until the web-applications are reachable
mvn -f $WORKSPACE/bakery-app/pom.xml -P docker-maven package \
    && docker-compose -f $COMPOSEFILE build \
    && docker-compose -f $COMPOSEFILE up -d \
    && docker-compose -f $COMPOSE_WAIT build \
    && docker-compose -f $COMPOSE_WAIT up \
    && exit 0

echo "unexpected error starting application containers from '$COMPOSEFILE'"
exit -1