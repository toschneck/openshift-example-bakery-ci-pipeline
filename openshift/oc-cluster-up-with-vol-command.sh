#!/usr/bin/env bash
if [ -z $OSENV ]; then
    OSENV="$HOME/apps/oc/data/ta-pipeline"
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
