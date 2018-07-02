#!/usr/bin/env bash
networkname="bakery-network"
#create network if not there -> skip
docker network create -d bridge $networkname || echo "network $networkname is created already"