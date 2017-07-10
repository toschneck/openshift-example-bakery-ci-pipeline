#!/usr/bin/env bash
cd $(dirname $(realpath $0))
set-e
FOLDER=$(pwd)

echo "ARGS: src $1 target $2 "
src=$1
dest=$2

$FOLDER/stage-images.sh ${src} ${dest} bakery-report-server:latest
$FOLDER/stage-images.sh ${src} ${dest} bakery-web-server:latest
$FOLDER/stage-images.sh ${src} ${dest} bakery-worker:latest