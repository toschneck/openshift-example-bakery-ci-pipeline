#!/usr/bin/env bash

#
#more infos: https://github.com/openshift-evangelists/oc-cluster-wrapper
echo "check if oc-cluster is installed!"
which oc-cluster
if [ $? != 0 ]; then
    echo "please install oc-cluster-wrapper: https://github.com/openshift-evangelists/oc-cluster-wrapper"
    exit -1
fi

if [ -z $OSENV ]; then
    OS_PROFILE="ta-pipeline"
fi
BASIC_IP=192.168.37.1

function stop(){
    oc-cluster down
    sudo ip addr delete $BASIC_IP/24 dev lo
}

if [[ $1 == 'stop' ]] ; then
    stop
    exit $?
fi

if [[ $1 == 'delete' ]] ; then
    stop
    oc-cluster destroy $OS_PROFILE
    exit $?
fi

echo "using openshift data space 'OSENV': $OS_PROFILE"

echo "add ip allias for $BASIC_IP to device 'lo'"
sudo ip addr add $BASIC_IP/24 dev lo

echo "create oc cluster for $OS_PROFILE"
export OC_CLUSTER_PUBLIC_HOSTNAME=$BASIC_IP
oc-cluster up $OS_PROFILE \
	 -e TZ=Europe/Berlin \
	 --version='v3.7.2'
oc-cluster plugin-install registryv2

#check status
echo "wait 5 sec" && sleep 5 \
    && oc login -u developer -p developer --insecure-skip-tls-verify=true "https://$BASIC_IP:8443" \
    && oc cluster status

## on errors:
#
# if`NodeUnderDiskPressure` edit `~/.oc/profiles/ta-pipeline/config/node-localhost/node-config.yaml`
#
#kubeletArguments:
#  eviction-hard:
#  - memory.available<100Mi
#  - nodefs.available<1%
#  - nodefs.inodesFree<1%
#  - imagefs.available<1%
echo "------ done!"