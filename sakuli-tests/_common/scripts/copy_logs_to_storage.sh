#!/usr/bin/env bash
set -e
if [[ $E2E_TEST_NAME == "" ]]; then
    echo "no 'E2E_TEST_NAME' defined for copy logs!" && exit 1
fi
if [[ $JOB_LOG_STORE == "" ]]; then
    echo "no 'JOB_LOG_STORE' defined for copy logs!" && exit 1
fi
echo "env: E2E_TEST_NAME=$E2E_TEST_NAME, JOB_LOG_STORE=$JOB_LOG_STORE"

cd $(dirname $(realpath $0))
FOLDER=$(pwd)

SUITE=$E2E_TEST_NAME
#CUR_DATE="$(date +%Y-%m-%d_%H-%M-%S)"

cd $FOLDER/../..
mkdir -p $JOB_LOG_STORE
cp -r $SUITE $JOB_LOG_STORE/
ls -la $JOB_LOG_STORE