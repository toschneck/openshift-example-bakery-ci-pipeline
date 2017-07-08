#!/usr/bin/env bash
cd $(dirname `which $0`)
FOLDER=$(pwd)

### add additional arguments
export ADD_ARGUMENT=""

### excute the different services
TESTSUITE='blueberry' BROWSER='firefox' SERVICENAME='sakuli_1' $FOLDER/execute_compose_test.sh $@ &

TESTSUITE='caramel' SERVICENAME='sakuli_2' $FOLDER/execute_compose_test.sh $@ &

TESTSUITE='chocolate' SERVICENAME='sakuli_3' $FOLDER/execute_compose_test.sh $@ &

TESTSUITE='order-pdf' SERVICENAME='sakuli_4' $FOLDER/execute_compose_test.sh $@ &
wait
exit $?
