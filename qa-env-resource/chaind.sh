#!/bin/bash

set -e

export GOGC=200
# default values
workdir="validator"
bin="bsc"
portInc=0
FullImmutabilityThreshold=90000
MinBlocksForBlobRequests=524288
DefaultExtraReserveForBlobRequests=28800
BreatheBlockInterval=600
LAST_FORK_MORE_DELAY=600

function startChaind() {
    workspace=/server/${workdir}

    PassedForkTime=`cat ${workspace}/hardforkTime.txt|grep passedHardforkTime|awk -F" " '{print $NF}'`
    LastHardforkTime=$(expr ${PassedForkTime} + ${LAST_FORK_MORE_DELAY})
    initLog=${workspace}/init.log
    rialtoHash=`cat ${initLog}|grep "database=chaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`

    ip=`ifconfig eth0|grep inet|grep -v inet6 |awk '{ print $2 }'`
    sed -i -e "s?FileRoot = \"\"?FileRoot = \"/mnt/efs/${workdir}/${ip}/\"?g" /server/${workdir}/config.toml
    mkdir -p /mnt/efs/${workdir}/${ip}
    HTTPPort=$((8545 + ${portInc}))
    WSPort=${HTTPPort}
    MetricsPort=$((6060 + ${portInc}))
    PProfPort=$((${MetricsPort} + 1))
    ${workspace}/${bin} --config ${workspace}/config.toml \
        --mine --vote --unlock {{validatorAddr}} --miner.etherbase {{validatorAddr}} --password ${workspace}/password.txt --blspassword ${workspace}/password.txt \
        --datadir ${workspace} \
        --rpc.allow-unprotected-txs --allow-insecure-unlock \
        --ws --ws.addr ${ip} --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" --http.api debug,trace,eth,txpool,net,web3,miner,admin,mev --ws.api debug,trace,eth,txpool,net,web3,miner,admin,mev \
        --metrics --metrics.addr 0.0.0.0 --metrics.port ${MetricsPort} \
        --pprof --pprof.port ${PProfPort} \
        --syncmode full --monitor.maliciousvote \
        --cache 10480 \
        --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${PassedForkTime} --override.fermi ${LastHardforkTime} \
        --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
        --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
        >> /mnt/efs/${workdir}/${ip}/bscnode.log 2>&1
}

function stopChaind() {
    pid=`ps -ef | grep /server/${workdir}/${bin} | grep -v grep | awk '{print $2}'`
    if [ -n "$pid" ]; then
        kill -TERM $pid
        for((i=1;i<=40;i++));
        do
            pid=`ps -ef | grep /server/${workdir}/${bin} | grep -v grep | awk '{print $2}'`
            if [ -z "$pid" ]; then
                break
            fi
            sleep 10
        done
    fi
}

CMD=$1

case $CMD in
-start)
    echo "start"
    startChaind
    ;;
-stop)
    echo "stop"
    stopChaind
    ;;
-restart)
    echo "restart"
    stopChaind
    sleep 3
    startChaind
    ;;
*)
    echo "Usage: chaind.sh -start | -stop | -restart .Or use systemctl start | stop | restart ${bin}.service "
    ;;
esac
