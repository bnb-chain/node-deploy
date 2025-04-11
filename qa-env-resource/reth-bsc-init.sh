#!/bin/bash

workspace=$(cd `dirname $0`; pwd)
workdir="validator"
bin="reth-bsc"

cp ${workspace}/${bin}.service /usr/lib/systemd/system/
cp /tmp/reth-bsc ${workspace}/${bin}
chmod +x ${workspace}/reth-bsc-chaind.sh ${workspace}/${bin}

service ${bin} stop
rm -rf /server/${workdir}
cp -r ${workspace} /server/${workdir}

systemctl daemon-reload
chkconfig ${bin} on
service ${bin} restart