#!/bin/bash
while ! httping -h bakery-web-server -p 8080 -c1 ; do echo "..."; sleep 1; done
while ! httping -h bakery-report-server -p 8080 -c1 ; do echo "..."; sleep 1; done
