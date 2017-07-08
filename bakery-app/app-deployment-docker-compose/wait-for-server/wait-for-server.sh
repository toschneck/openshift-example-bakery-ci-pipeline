#!/bin/bash
if [ -z $BAKERY_BAKERY_URL ]; then
    BAKERY_BAKERY_URL="http://bakery-web-server/bakery/"
fi
if [ -z $BAKERY_REPORT_URL ]; then
    BAKERY_REPORT_URL="http://bakery-report-server/report/"
fi
echo "BAKERY_BAKERY_URL=$BAKERY_BAKERY_URL, BAKERY_REPORT_URL=$BAKERY_REPORT_URL"

while ! httping -h bakery-web-server -p 8080 -c1 ; do echo "..."; sleep 1; done
while ! httping -h bakery-report-server -p 8080 -c1 ; do echo "..."; sleep 1; done
