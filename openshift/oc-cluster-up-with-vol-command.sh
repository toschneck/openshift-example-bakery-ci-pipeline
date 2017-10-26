#!/usr/bin/env bash
if [ -z $OSENV ]; then
    OSENV="$HOME/apps/oc/data/ta-pipeline"
fi
BASIC_IP=192.168.37.1

function stop(){
    oc cluster down
    sudo ip addr delete $BASIC_IP/24 dev lo
}

if [[ $1 == 'stop' ]] ; then
    stop
    exit $?
fi

if [[ $1 == 'delete' ]] ; then
    stop
    sudo rm -rfv $OSENV
    exit $?
fi

mkdir -p $OSENV/config
mkdir -p $OSENV/data
mkdir -p $OSENV/vol
echo "using openshift data space 'OSENV': $OSENV"

echo "add ip allias for $BASIC_IP to device 'lo'"
sudo ip addr add $BASIC_IP/24 dev lo

echo "create oc cluster for $OSENV"
oc cluster up \
	 --version='v3.6.0' \
	 --use-existing-config=true \
	 --host-config-dir=$OSENV/config \
	 --host-data-dir=$OSENV/data \
	 --host-pv-dir=$OSENV/vol \
	 --public-hostname=$BASIC_IP

# if persistence volumens can't write try:
# echo "wait 10 sec" && sleep 10 && sudo chown $(id -u):$(id -g) -R $OSENV/vol
