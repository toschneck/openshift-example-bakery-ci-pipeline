#!/usr/bin/env bash
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

$FOLDER/create_sakuli-test.sh build &
#$FOLDER/create_wait-server.sh build &
wait

### test if app is up
#$FOLDER/create_wait-server.sh
### excute the different services
# Example Sakuli Testsuite
$FOLDER/create_sakuli-test.sh 'blueberry' &
#$FOLDER/create_sakuli-test.sh 'caramel' &
#$FOLDER/create_sakuli-test.sh 'chocolate' &
#$FOLDER/create_sakuli-test.sh 'order-pdf' &

wait
exit $?
