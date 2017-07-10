#!/usr/bin/env bash
set -e
cd $(dirname $(realpath $0))
FOLDER=$(pwd)

SUITE=$1
if [[ $SUITE == "" ]]; then
    echo "no suite defined for uploads logs!"
fi
if [ -z $NEXUS_HOST ] ;then
    echo "NEXUS_HOST not defined!"
    exit -1
fi

CUR_DATE="$(date +%Y-%m-%d_%H-%M-%S)"
ZIPNAME=$SUITE-$CUR_DATE.zip
ART=${SUITE}-logs

cd $FOLDER
zip -r $ZIPNAME ./$SUITE

curl -v -F r=releases -F hasPom=false -F e=zip -F g=sakuli -F a=${ART} -F v=${CUR_DATE} -F p=zip \
    -F file=@./${ZIPNAME} -u admin:admin123 "http://${NEXUS_HOST}/service/local/artifact/maven/content"
exitcode=$?
echo "uploaded $ZIPNAME to $NEXUS_HOST!"
echo ""
echo "DOWNLOAD LOGS: http://${NEXUS_HOST}/service/local/repositories/releases/content/sakuli/${ART}/${CUR_DATE}/${ART}-${CUR_DATE}.zip"
echo ""
exit $exitcode
