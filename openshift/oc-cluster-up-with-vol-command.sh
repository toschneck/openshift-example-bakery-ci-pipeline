#!/usr/bin/env bash

if [ -z $OSENV ]; then
    OSENV="$HOME/apps/oc/data/ta-pipeline"
fi

if [[ $1 == 'stop' ]] ; then
    oc cluster down
    exit $?
fi
if [[ $1 == 'delete' ]] ; then
    oc cluster down
    sudo rm -rf $OSENV
    exit $?
fi

mkdir -p $OSENV/config
mkdir -p $OSENV/data
mkdir -p $OSENV/vol
echo "using openshift data space 'OSENV': $OSENV"

echo "create oc cluster for $OSENV"
oc cluster up \
	 --version='v3.6.0' \
	 --use-existing-config=true \
	 --host-config-dir=$OSENV/config \
	 --host-data-dir=$OSENV/data \
	 --host-pv-dir=$OSENV/vol \
	 --public-hostname=$(hostname)

# if persistence volumens can't write try: sudo chown $(id -u):$(id -g) -R $OSENV/vol
