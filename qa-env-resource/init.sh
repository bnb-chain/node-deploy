#!/bin/bash

workspace=$(cd `dirname $0`; pwd)

cp ${workspace}/bsc.service /usr/lib/systemd/system/
chmod +x ${workspace}/start.sh ${workspace}/chaind.sh ${workspace}/bsc

service bsc stop
rm -rf /server/validator
mv  ${workspace} /server/validator

/server/validator/start.sh