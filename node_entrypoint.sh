#!/usr/bin/env bash
set -e

# Node Entrypoint for Docker Compose running BSC geth

# Ensure environment variables exist
if [ -z "$NODE_TYPE" ] || [ -z "$NODE_INDEX" ]; then
    echo "ERROR: NODE_TYPE and NODE_INDEX must be provided"
    exit 1
fi

if [ -z "$RIALTO_HASH" ]; then
    echo "ERROR: RIALTO_HASH not set by env"
    exit 1
fi

workspace="/node_deploy"
geth_bin="${workspace}/bin/geth"

echo "Starting BSC $NODE_TYPE node $NODE_INDEX..."

function start_node() {
    local datadir=$1
    local extra_args=""

    # Only Validator nodes require mining and unlocking parameters
    if [ "$NODE_TYPE" = "node" ]; then
        cons_addr="0x$(jq -r .address ${datadir}/keystore/*)"
        extra_args="--mine --vote --unlock ${cons_addr} --miner.etherbase ${cons_addr} --password ${datadir}/password.txt --blspassword ${datadir}/password.txt"
    fi

    # Execute geth (replaces the bash shell process with geth)
    exec ${geth_bin} --config ${datadir}/config.toml \
        --datadir ${datadir} \
        --nodekey ${datadir}/geth/nodekey \
        --cache 512 \
        --rpc.allow-unprotected-txs --allow-insecure-unlock \
        --ws --ws.addr 0.0.0.0 --ws.port 8545 \
        --http --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain "*" \
        --metrics --metrics.addr 0.0.0.0 --metrics.port 6060 \
        --pprof --pprof.addr 0.0.0.0 --pprof.port 7060 \
        --gcmode full --syncmode full --monitor.maliciousvote \
        --rialtohash ${RIALTO_HASH} \
        --override.passedforktime ${PASSED_FORK_TIME} \
        --override.lorentz ${PASSED_FORK_TIME} \
        --override.maxwell ${PASSED_FORK_TIME} \
        --override.fermi ${LAST_HARDFORK_TIME} \
        --override.osaka ${LAST_HARDFORK_TIME} \
        --override.mendel ${LAST_HARDFORK_TIME} \
        --override.pasteur ${LAST_HARDFORK_TIME} \
        --override.immutabilitythreshold ${FULL_IMMUTABILITY_THRESHOLD} \
        --override.breatheblockinterval ${BREATHE_BLOCK_INTERVAL} \
        --override.minforblobrequest ${MIN_FOR_BLOB_REQUESTS} \
        --override.defaultextrareserve ${DEFAULT_EXTRA_RESERVE} \
        $extra_args
}

if [ "$NODE_TYPE" = "node" ]; then
    start_node "${workspace}/.local/node${NODE_INDEX}"
elif [ "$NODE_TYPE" = "sentry" ]; then
    start_node "${workspace}/.local/sentry${NODE_INDEX}"
elif [ "$NODE_TYPE" = "full" ]; then
    start_node "${workspace}/.local/fullnode${NODE_INDEX}"
else
    echo "Unknown NODE_TYPE: $NODE_TYPE"
    exit 1
fi
