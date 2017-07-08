#!/usr/bin/env bash
cd $(dirname `which $0`)
FOLDER=$(pwd)

# skip the result evaluation - it will be done by the omd monitoring system
export SKIP_COPY_LOGS=true
export OMD_SERVER="true"

cleanup ()
{
kill -s SIGTERM $!
exit 0
}

trap cleanup SIGINT SIGTERM

### run each suite every x seconds, until CTRL + C
SLEEP_SEC=5
while [ 1 ]
do
    $FOLDER/execute_all.sh &
    wait $!
    echo "sleep $SLEEP_SEC seconds"
    sleep $SLEEP_SEC;
done
exit 0
