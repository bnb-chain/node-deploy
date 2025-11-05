#!/bin/bash

set -e

# default values
workdir="validator"
bin="reth-bsc"
portInc=0
FullImmutabilityThreshold=90000
MinBlocksForBlobRequests=524288
DefaultExtraReserveForBlobRequests=28800
BreatheBlockInterval=600
LAST_FORK_MORE_DELAY=18000000
LOG_LEVEL="debug"
KEYPASS="123456"
ENABLE_MINING=true

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

    # read flags from config.toml
    # Modify fork times in genesis.json for reth-bsc: all forks at PassedForkTime except Maxwell at LastHardforkTime
    jq --arg passedTime "$PassedForkTime" --arg maxwellTime "$LastHardforkTime" '
        .config.shanghaiTime = ($passedTime | tonumber) |
        .config.keplerTime = ($passedTime | tonumber) |
        .config.feynmanTime = ($passedTime | tonumber) |
        .config.feynmanFixTime = ($passedTime | tonumber) |
        .config.cancunTime = ($passedTime | tonumber) |
        .config.haberTime = ($passedTime | tonumber) |
        .config.haberFixTime = ($passedTime | tonumber) |
        .config.lorentzTime = ($passedTime | tonumber) |
        .config.maxwellTime = ($maxwellTime | tonumber) |
        .config.bohrTime = ($passedTime | tonumber) |
        .config.tychoTime = ($passedTime | tonumber) |
        .config.pragueTime = ($passedTime | tonumber) |
        .config.pascalTime = ($passedTime | tonumber)
    ' ${workspace}/genesis.json > ${workspace}/genesis_reth.json
    
    # Get the first bootnode enode from BootstrapNodes configuration
    # Extract the complete first bootnode entry (including the full enode:// URL)
    bootnode_enode=$(grep -E "BootstrapNodes" ${workspace}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
    staic_enode=$(grep -E "StaticNodes" ${workspace}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
    
    # Extract discovery port from the current node's config.toml ListenAddr
    discovery_port=$(grep "ListenAddr" ${workspace}/config.toml | sed 's/.*:\([0-9]*\).*/\1/')
    auth_port=8551
    
    nodekey_path=$(find ${workspace}/geth/nodekey -type f | head -1)
    peer_conf=()
    if [ -n "${bootnode_enode}" ]; then
        peer_conf+=(--bootnodes ${bootnode_enode})
    fi
    if [ -n "${staic_enode}" ]; then
        peer_conf+=(--trusted-peers ${staic_enode})
    fi

    mining_conf=()
    if [ "${ENABLE_MINING}" = "true" ]; then
        # Detect keystore path dynamically
        keystore_path=$(find ${workspace}/keystore -name "UTC--*" -type f | head -1)
        # Determine BLS signer CLI args (prefer CLI over env)
        # Priority:
        # 1) BSC_BLS_PRIVATE_KEY -> use direct private key (dev only)
        # 2) BSC_BLS_KEYSTORE_PATH + BSC_BLS_KEYSTORE_PASSWORD -> use provided keystore
        # 3) Auto-detected keystore in node dir + KEYPASS from .env
        bls_keystore_path=$(find ${workspace}/bls/keystore -name "*.json" -type f | head -1)
        bls_cli_args=()
        if [ -n "${BSC_BLS_PRIVATE_KEY}" ]; then
            bls_cli_args+=(--bls.private-key "${BSC_BLS_PRIVATE_KEY}")
        elif [ -n "${BSC_BLS_KEYSTORE_PATH}" ] && [ -n "${BSC_BLS_KEYSTORE_PASSWORD}" ]; then
            bls_cli_args+=(--bls.keystore-path "${BSC_BLS_KEYSTORE_PATH}" --bls.keystore-password "${BSC_BLS_KEYSTORE_PASSWORD}")
        else
            if [ -z "${bls_keystore_path}" ]; then
                echo "WARNING: No BLS keystore found for node${nodeIndex}; reth-bsc may fall back to env if configured" >&2
            fi
            bls_cli_args+=(--bls.keystore-path "${bls_keystore_path}" --bls.keystore-password "${KEYPASS}")
        fi
        mining_conf+=(--mining.enabled)
        mining_conf+=(--mining.keystore-path ${keystore_path})
        mining_conf+=(--mining.keystore-password ${KEYPASS})
        mining_conf+=( "${bls_cli_args[@]}" )
    fi

    evn_conf=()
    enable_evn=$(grep -E "EnableEVNFeatures" ${workspace}/config.toml | grep -o 'true' | head -1)
    if [ "${enable_evn}" = "true" ]; then
        evn_conf+=(--evn.enabled)
        add_nodeid=$(grep -E "EVNNodeIDsToAdd" ${workspace}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${add_nodeid}" ]; then
            evn_conf+=(--evn.add-nodeid ${add_nodeid})
        fi
        remove_nodeid=$(grep -E "EVNNodeIDsToRemove" ${workspace}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${remove_nodeid}" ]; then
            evn_conf+=(--evn.remove-nodeid ${remove_nodeid})
        fi
        whitelist_nodeid=$(grep -E "EVNNodeIdsWhitelist" ${workspace}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${whitelist_nodeid}" ]; then
            evn_conf+=(--evn.whitelist-nodeids ${whitelist_nodeid})
        fi
        proxyed_val=$(grep -E "ProxyedValidatorAddresses" ${workspace}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${proxyed_val}" ]; then
            evn_conf+=(--evn.proxyed-validator ${proxyed_val})
        fi
    fi

    echo "nodekey_path: ${nodekey_path}, peer_conf: ${peer_conf[@]}, evn_conf: ${evn_conf[@]}, mining_conf: ${mining_conf[@]}"
    
    # Run reth-bsc node
    env RUST_LOG=${LOG_LEVEL} BREATHE_BLOCK_INTERVAL=${BreatheBlockInterval} ${workspace}/${bin} node \
        --chain ${workspace}/genesis_reth.json \
        --datadir ${workspace} \
        --genesis-hash ${rialtoHash} \
        --http \
        --http.addr 0.0.0.0 \
        --http.port ${HTTPPort} \
        --p2p-secret-key ${nodekey_path} \
        --ws \
        --ws.addr 0.0.0.0 \
        --ws.port $((${WSPort})) \
        --discovery.addr 0.0.0.0 \
        --discovery.port ${discovery_port} \
        --authrpc.port ${auth_port} \
        --port ${discovery_port} \
        ${peer_conf[@]} \
        ${evn_conf[@]} \
        ${mining_conf[@]} \
        --log.stdout.format log-fmt \
        >> /mnt/efs/${workdir}/${ip}/reth.log 2>&1
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
