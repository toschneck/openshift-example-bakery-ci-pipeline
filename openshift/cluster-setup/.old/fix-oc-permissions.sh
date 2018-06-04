#!/usr/bin/env bash
if [ -z $OSENV ]; then
    OSENV="$HOME/apps/oc/data/ta-pipeline"
fi

# if persistence volumens can't write try:
sudo chown $(id -u):$(id -g) -R $OSENV/vol $OSENV/pv
ls -lah $OSENV/*
