#!/bin/bash

export GOGC=200
# default values
FullImmutabilityThreshold=90000
MinBlocksForBlobRequests=524288
DefaultExtraReserveForBlobRequests=28800
BreatheBlockInterval=600
LAST_FORK_MORE_DELAY=200

function startChaind() {
    workspace=/server/validator

    PassedForkTime=`cat ${workspace}/hardforkTime.txt|grep passedHardforkTime|awk -F" " '{print $NF}'`
    LastHardforkTime=$(expr ${PassedForkTime} + ${LAST_FORK_MORE_DELAY})
    initLog=${workspace}/init.log
    rialtoHash=`cat ${initLog}|grep "database=chaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`

    ip=`ifconfig eth0|grep inet|grep -v inet6 |awk '{ print $2 }'`
    sed -i -e "s?FileRoot = \"\"?FileRoot = \"/mnt/efs/validator/${ip}/\"?g" /server/validator/config.toml
    mkdir -p /mnt/efs/validator/${ip}
    ${workspace}/bsc --config ${workspace}/config.toml \
        --datadir ${workspace} \
        --password ${workspace}/password.txt \
        --blspassword ${workspace}/password.txt \
        --unlock {{validatorAddr}} --miner.etherbase {{validatorAddr}} --rpc.allow-unprotected-txs --allow-insecure-unlock \
        --ws --ws.port 8545 --ws.addr ${ip} --http.addr 0.0.0.0 --http.corsdomain "*" \
        --metrics --metrics.addr 0.0.0.0 \
        --pprof --pprof.port 6061 \
        --syncmode snap --mine --vote --monitor.maliciousvote \
        --cache 10480 \
        --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.pascal ${PassedForkTime} --override.prague ${PassedForkTime} --override.lorentz ${LastHardforkTime} \
        --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
        --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
        >> /mnt/efs/validator/${ip}/bscnode.log 2>&1
}

function stopChaind() {
    pid=`ps -ef | grep /server/validator/bsc | grep -v grep | awk '{print $2}'`
    if [ -n "$pid" ]; then
        for((i=1;i<=4;i++));
        do
            kill $pid
            sleep 5
            pid=`ps -ef | grep /server/validator/bsc | grep -v grep | awk '{print $2}'`
            if [ -z "$pid" ]; then
                break
            elif [ $i -eq 4 ]; then
                kill -9 $kid
            fi
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
    stopChaind
    sleep 3
    startChaind
    ;;
*)
    echo "Usage: chaind.sh -start | -stop | -restart .Or use systemctl start | stop | restart bsc.service "
    ;;
esac