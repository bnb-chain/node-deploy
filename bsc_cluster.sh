#!/usr/bin/env bash

# Exit script on error
set -e

basedir=$(
    cd $(dirname $0)
    pwd
)
workspace=${basedir}
source ${workspace}/.env
size=$((BSC_CLUSTER_SIZE))
stateScheme="hash"
dbEngine="leveldb"
gcmode="full"
sleepBeforeStart=15
sleepAfterStart=10

# Validation function for reth-bsc configuration
function validate_reth_config() {
    # Check if RETH_NODE_COUNT is set and valid
    if [ -z "$RETH_NODE_COUNT" ]; then
        RETH_NODE_COUNT=0
        echo "RETH_NODE_COUNT not set, defaulting to 0 (all geth nodes)"
        return 0
    fi
    
    # Check if RETH_NODE_COUNT is not greater than total cluster size
    if [ $RETH_NODE_COUNT -gt $size ]; then
        echo "ERROR: RETH_NODE_COUNT ($RETH_NODE_COUNT) cannot be greater than BSC_CLUSTER_SIZE ($size)"
        echo "Please adjust RETH_NODE_COUNT in .env file to be <= $size"
        exit 1
    fi
    
    # Check if RETH_NODE_COUNT is negative
    if [ $RETH_NODE_COUNT -lt 0 ]; then
        echo "ERROR: RETH_NODE_COUNT ($RETH_NODE_COUNT) cannot be negative"
        echo "Please set RETH_NODE_COUNT to a value between 0 and $size in .env file"
        exit 1
    fi
    
    # If RETH_NODE_COUNT > 0, check if reth-bsc binary exists and is executable
    if [ $RETH_NODE_COUNT -gt 0 ]; then
        if [ -z "$RETH_BSC_BINARY_PATH" ]; then
            echo "ERROR: RETH_BSC_BINARY_PATH is not set in .env file"
            echo "Please set RETH_BSC_BINARY_PATH to the path of your reth-bsc binary"
            exit 1
        fi
        
        if [ ! -f "$RETH_BSC_BINARY_PATH" ]; then
            echo "ERROR: reth-bsc binary not found at: $RETH_BSC_BINARY_PATH"
            echo "Please check the RETH_BSC_BINARY_PATH in .env file and ensure the binary exists"
            exit 1
        fi
        
        if [ ! -x "$RETH_BSC_BINARY_PATH" ]; then
            echo "ERROR: reth-bsc binary is not executable: $RETH_BSC_BINARY_PATH"
            echo "Please make the binary executable with: chmod +x $RETH_BSC_BINARY_PATH"
            exit 1
        fi
        
        echo "✓ Validated: Will run $RETH_NODE_COUNT reth-bsc nodes (node0-node$((RETH_NODE_COUNT-1))) and $((size-RETH_NODE_COUNT)) geth nodes"
    else
        echo "✓ Validated: Will run all $size nodes with geth (no reth-bsc nodes)"
    fi
}

# stop geth client and reth-bsc
function exit_previous() {
    ValIdx=$1
    if [ ! -z $ValIdx ]; then
        if [ $ValIdx -lt $RETH_NODE_COUNT ]; then
            # Stop reth-bsc for reth nodes (first RETH_NODE_COUNT nodes)
            ps -ef | grep reth-bsc | grep -v grep | awk '{print $2}' | xargs -r kill
        else
            # Stop geth for other nodes
            ps -ef  | grep geth$ValIdx | grep config |awk '{print $2}' | xargs -r kill
        fi
    else
        # Stop all nodes
        ps -ef | grep reth-bsc | grep -v grep | awk '{print $2}' | xargs -r kill
        for ((i = 0; i < size; i++)); do
            ps -ef  | grep geth$i | grep config |awk '{print $2}' | xargs -r kill
        done
    fi
    sleep ${sleepBeforeStart}
}

function create_validator() {
    rm -rf ${workspace}/.local
    mkdir -p ${workspace}/.local

    for ((i = 0; i < size; i++)); do
        cp -r ${workspace}/keys/validator${i} ${workspace}/.local/
        cp -r ${workspace}/keys/bls${i} ${workspace}/.local/
    done
}

function prepare_bsc_client() {
    if [ ${useLatestBscClient} = true ]; then
        if [ ! -f "${workspace}/bsc/Makefile" ]; then
            cd ${workspace}
            git clone https://github.com/bnb-chain/bsc.git
        fi
        cd ${workspace}/bsc && git pull && make geth && mv -f ${workspace}/bsc/build/bin/geth ${workspace}/bin/
    fi
}
# reset genesis, but keep edited genesis-template.json
function reset_genesis() {
    if [ ! -f "${workspace}/genesis/genesis-template.json" ]; then
        cd ${workspace} && git submodule update --init --recursive genesis
        cd ${workspace}/genesis && git reset --hard ${GENESIS_COMMIT}
    fi
    cd ${workspace}/genesis
    cp genesis-template.json genesis-template.json.bk
    cp scripts/init_holders.template scripts/init_holders.template.bk
    git stash
    cd ${workspace} && git submodule update --remote --recursive genesis && cd ${workspace}/genesis
    git reset --hard ${GENESIS_COMMIT}
    mv genesis-template.json.bk genesis-template.json
    mv scripts/init_holders.template.bk scripts/init_holders.template

    poetry install --no-root
    npm install
    rm -rf lib/forge-std
    forge install --no-git foundry-rs/forge-std@v1.7.3
    cd lib/forge-std/lib
    rm -rf ds-test
    git clone https://github.com/dapphub/ds-test
}

function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf

    passedHardforkTime=$(expr $(date +%s) + ${PASSED_FORK_DELAY})
    echo "passedHardforkTime "${passedHardforkTime} > ${workspace}/.local/hardforkTime.txt
    initHolders=${INIT_HOLDER}
    for ((i = 0; i < size; i++)); do
        for f in ${workspace}/.local/validator${i}/keystore/*; do
            cons_addr="0x$(cat ${f} | jq -r .address)"
            initHolders=${initHolders}","${cons_addr}
            fee_addr=${cons_addr}
        done

        targetDir=${workspace}/.local/node${i}
        mkdir -p ${targetDir} && cd ${targetDir}
        cp ${workspace}/keys/password.txt ./
        cp ${workspace}/.local/hardforkTime.txt ./
        bbcfee_addrs=${fee_addr}
        powers="0x000001d1a94a2000" #2000000000000
        mv ${workspace}/.local/bls${i}/bls ./ && rm -rf ${workspace}/.local/bls${i}
        vote_addr=0x$(cat ./bls/keystore/*json | jq .pubkey | sed 's/"//g')
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/genesis/validators.conf
        if [ ${EnableSentryNode} = true ]; then
            mkdir -p ${workspace}/.local/sentry${i}
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        mkdir -p ${workspace}/.local/fullnode0
    fi
    rm -f ${workspace}/.local/hardforkTime.txt

    cd ${workspace}/genesis/
    git checkout HEAD contracts
    sed -i -e  's/alreadyInit = true;/turnLength = 16;alreadyInit = true;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    sed -i -e  's/public onlyCoinbase onlyZeroGasPrice {/public onlyCoinbase onlyZeroGasPrice {if (block.number < 300) return;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    
    poetry run python -m scripts.generate generate-validators
    poetry run python -m scripts.generate generate-init-holders "${initHolders}"
    poetry run python -m scripts.generate dev \
      --dev-chain-id "${CHAIN_ID}" \
      --init-burn-ratio "1000" \
      --init-felony-slash-scope "60" \
      --breathe-block-interval "10 minutes" \
      --block-interval "3 seconds" \
      --stake-hub-protector "${INIT_HOLDER}" \
      --unbond-period "2 minutes" \
      --downtime-jail-time "2 minutes" \
      --felony-jail-time "3 minutes" \
      --misdemeanor-threshold "50" \
      --felony-threshold "150" \
      --init-voting-period "2 minutes / BLOCK_INTERVAL" \
      --init-min-period-after-quorum "uint64(1 minutes / BLOCK_INTERVAL)" \
      --governor-protector "${INIT_HOLDER}" \
      --init-minimal-delay "1 minutes" \
      --token-recover-portal-protector "${INIT_HOLDER}"
}

function initNetwork() {
    cd ${workspace}
    for ((i = 0; i < size; i++)); do
        mkdir ${workspace}/.local/node${i}/geth
        cp ${workspace}/keys/validator-nodekey${i} ${workspace}/.local/node${i}/geth/nodekey
        mv ${workspace}/.local/validator${i}/keystore ${workspace}/.local/node${i}/ && rm -rf ${workspace}/.local/validator${i}
        if [ ${EnableSentryNode} = true ]; then
            mkdir ${workspace}/.local/sentry${i}/geth
            cp ${workspace}/keys/sentry-nodekey${i} ${workspace}/.local/sentry${i}/geth/nodekey
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        mkdir ${workspace}/.local/fullnode0/geth
        cp ${workspace}/keys/fullnode-nodekey0 ${workspace}/.local/fullnode0/geth/nodekey
    fi
    
    init_extra_args=""
    if [ ${EnableSentryNode} = true ]; then
        init_extra_args="--init.sentrynode-size ${size} --init.sentrynode-ports 30411"
    fi
    if [ ${EnableFullNode} = true ]; then
        init_extra_args="${init_extra_args} --init.fullnode-size 1 --init.fullnode-ports 30511"
    fi
    if [ "${RegisterNodeID}" = true ]; then
        if [ "${EnableSentryNode}" = true ]; then
            init_extra_args="${init_extra_args} --init.evn-sentry-register"
        else
            init_extra_args="${init_extra_args} --init.evn-validator-register"
        fi
    fi
    if [ "${EnableEVNWhitelist}" = true ]; then
        if [ "${EnableSentryNode}" = true ]; then
            init_extra_args="${init_extra_args} --init.evn-sentry-whitelist"
        else
            init_extra_args="${init_extra_args} --init.evn-validator-whitelist"
        fi
    fi
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local --init.size=${size} --config ${workspace}/config.toml ${init_extra_args} ${workspace}/genesis/genesis.json
    rm -f ${workspace}/*bsc.log*
    for ((i = 0; i < size; i++)); do
        sed -i -e '/"<nil>"/d' ${workspace}/.local/node${i}/config.toml
        # init genesis
        initLog=${workspace}/.local/node${i}/init.log
        if  [ $i -eq 0 ] ; then
                ${workspace}/bin/geth --datadir ${workspace}/.local/node${i} init --state.scheme ${stateScheme} --db.engine ${dbEngine} ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        elif  [ $i -lt $RETH_NODE_COUNT ] ; then
            # Skip geth init for reth-bsc nodes, just copy genesis and create a dummy init log
            cp ${workspace}/genesis/genesis.json ${workspace}/.local/node${i}/genesis.json
            echo "reth-bsc init: genesis.json copied for reth-bsc node${i}" > "${initLog}" 2>&1
        else
            ${workspace}/bin/geth --datadir ${workspace}/.local/node${i} init --state.scheme path --db.engine pebble ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        fi
        rm -f ${workspace}/.local/node${i}/*bsc.log*

        if [ ${EnableSentryNode} = true ]; then
            sed -i -e '/"<nil>"/d' ${workspace}/.local/sentry${i}/config.toml
            initLog=${workspace}/.local/sentry${i}/init.log
            ${workspace}/bin/geth --datadir ${workspace}/.local/sentry${i} init --state.scheme path --db.engine pebble ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
            rm -f ${workspace}/.local/sentry${i}/*bsc.log*
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        sed -i -e '/"<nil>"/d' ${workspace}/.local/fullnode0/config.toml
        sed -i -e 's/EnableEVNFeatures = true/EnableEVNFeatures = false/g' ${workspace}/.local/fullnode0/config.toml
        initLog=${workspace}/.local/fullnode0/init.log
        ${workspace}/bin/geth --datadir ${workspace}/.local/fullnode0 init --state.scheme path --db.engine pebble ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        rm -f ${workspace}/.local/fullnode0/*bsc.log*
    fi
}

function start_reth_bsc() {
    local nodeIndex=$1
    local HTTPPort=$2
    local WSPort=$3
    local PassedForkTime=$4
    local LastHardforkTime=$5
    local rialtoHash=$6
    
    # Copy and modify genesis.json for reth-bsc with correct fork timing
    cp ${workspace}/genesis/genesis.json ${workspace}/.local/node${nodeIndex}/genesis.json
    
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
    ' ${workspace}/.local/node${nodeIndex}/genesis.json > ${workspace}/.local/node${nodeIndex}/genesis_reth.json
    
    # Get the first bootnode enode from BootstrapNodes configuration
    # Extract the complete first bootnode entry (including the full enode:// URL)
    bootnode_enode=$(grep "BootstrapNodes" ${workspace}/.local/node1/config.toml 2>/dev/null | sed 's/.*\[\s*"//;s/".*//;q')
    
    # If we can't find it in the config, use the default first entry
    if [ -z "$bootnode_enode" ]; then
        bootnode_enode="enode://b78cba3067e3043e0d6b72931c29ae463c10533b149bdc23de54304cacf5f434e903ae2b8d4485f1ad103e6882301a77f03b679a51e169ab4afcab635cb614c2@127.0.0.1:30311"
    fi
    
    # Extract discovery port from the current node's config.toml ListenAddr
    discovery_port=$(grep "ListenAddr" ${workspace}/.local/node${nodeIndex}/config.toml 2>/dev/null | sed 's/.*:\([0-9]*\).*/\1/')
    if [ -z "$discovery_port" ]; then
        discovery_port=$((30311 + nodeIndex))  # Default port based on node index (30311 + i)
    fi
    
    # Detect keystore path dynamically
    keystore_path=$(find ${workspace}/.local/node${nodeIndex}/keystore -name "UTC--*" -type f | head -1)
    
    # Determine BLS signer CLI args (prefer CLI over env)
    # Priority:
    # 1) BSC_BLS_PRIVATE_KEY -> use direct private key (dev only)
    # 2) BSC_BLS_KEYSTORE_PATH + BSC_BLS_KEYSTORE_PASSWORD -> use provided keystore
    # 3) Auto-detected keystore in node dir + KEYPASS from .env
    bls_keystore_path=$(find ${workspace}/.local/node${nodeIndex}/bls/keystore -name "*.json" -type f | head -1)
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
    
    # Run reth-bsc node
    nohup env RUST_LOG=debug BREATHE_BLOCK_INTERVAL=${BreatheBlockInterval} ${RETH_BSC_BINARY_PATH} node \
        --chain ${workspace}/.local/node${nodeIndex}/genesis_reth.json \
        --datadir ${workspace}/.local/node${nodeIndex} \
        --genesis-hash ${rialtoHash} \
        --http \
        --http.addr 0.0.0.0 \
        --http.port ${HTTPPort} \
        --ws \
        --ws.addr 0.0.0.0 \
        --ws.port $((${WSPort})) \
        --discovery.addr 0.0.0.0 \
        --discovery.port ${discovery_port} \
        --bootnodes ${bootnode_enode} \
        --mining.enabled \
        --mining.keystore-path ${keystore_path} \
        --mining.keystore-password ${KEYPASS} "${bls_cli_args[@]}" \
        --log.stdout.format log-fmt \
        >> ${workspace}/.local/node${nodeIndex}/reth.log 2>&1 &
}

function native_start() {
    PassedForkTime=`cat ${workspace}/.local/node0/hardforkTime.txt|grep passedHardforkTime|awk -F" " '{print $NF}'`
    LastHardforkTime=$(expr ${PassedForkTime} + ${LAST_FORK_MORE_DELAY})
    rialtoHash=`cat ${workspace}/.local/node0/init.log|grep "database=chaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`

    ValIdx=$1
    for ((i = 0; i < size; i++));do
        if [ ! -z $ValIdx ] && [ $i -ne $ValIdx ]; then
            continue
        fi

        for j in ${workspace}/.local/node${i}/keystore/*;do
            cons_addr="0x$(cat ${j} | jq -r .address)"
        done

        HTTPPort=$((8545 + i*2))
        WSPort=${HTTPPort}
        MetricsPort=$((6060 + i*2))
        PProfPort=$((7060 + i*2))
 
        # Handle reth-bsc for first RETH_NODE_COUNT nodes, geth for others
        if [ $i -lt $RETH_NODE_COUNT ]; then
            start_reth_bsc $i $HTTPPort $WSPort $PassedForkTime $LastHardforkTime $rialtoHash
        else
            # geth may be replaced
            cp ${workspace}/bin/geth ${workspace}/.local/node${i}/geth${i}
            # update `config` in genesis.json
            # ${workspace}/.local/node${i}/geth${i} dumpgenesis --datadir ${workspace}/.local/node${i} | jq . > ${workspace}/.local/node${i}/genesis.json
            # run BSC node
            nohup  ${workspace}/.local/node${i}/geth${i} --config ${workspace}/.local/node${i}/config.toml \
                --mine --vote --password ${workspace}/.local/node${i}/password.txt --unlock ${cons_addr} --miner.etherbase ${cons_addr} --blspassword ${workspace}/.local/node${i}/password.txt \
                --datadir ${workspace}/.local/node${i} \
                --nodekey ${workspace}/.local/node${i}/geth/nodekey \
                --rpc.allow-unprotected-txs --allow-insecure-unlock  \
                --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
                --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
                --pprof --pprof.addr localhost --pprof.port ${PProfPort} \
                --gcmode ${gcmode} --syncmode full --monitor.maliciousvote \
                --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
                --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
                --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
                >> ${workspace}/.local/node${i}/bsc-node.log 2>&1 &
        fi
        
        if [ ${EnableSentryNode} = true ]; then
            cp ${workspace}/bin/geth ${workspace}/.local/sentry${i}/geth${i}
            nohup  ${workspace}/.local/sentry${i}/geth${i} --config ${workspace}/.local/sentry${i}/config.toml \
                --datadir ${workspace}/.local/sentry${i} \
                --nodekey ${workspace}/.local/sentry${i}/geth/nodekey \
                --rpc.allow-unprotected-txs --allow-insecure-unlock  \
                --ws.addr 0.0.0.0 --ws.port $((WSPort+1)) --http.addr 0.0.0.0 --http.port $((HTTPPort+1)) --http.corsdomain "*" \
                --metrics --metrics.addr localhost --metrics.port $((MetricsPort+1)) --metrics.expensive \
                --pprof --pprof.addr localhost --pprof.port $((PProfPort+1)) \
                --gcmode ${gcmode} --syncmode full --monitor.maliciousvote \
                --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
                --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
                --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
                >> ${workspace}/.local/sentry${i}/bsc-node.log 2>&1 &
        fi
    done

    if [ ${EnableFullNode} = true ]; then
        cp ${workspace}/bin/geth ${workspace}/.local/fullnode0/geth0
        nohup  ${workspace}/.local/fullnode0/geth0 --config ${workspace}/.local/fullnode0/config.toml \
            --datadir ${workspace}/.local/fullnode0 \
            --nodekey ${workspace}/.local/fullnode0/geth/nodekey \
            --rpc.allow-unprotected-txs --allow-insecure-unlock  \
            --ws.addr 0.0.0.0 --ws.port $((8645)) --http.addr 0.0.0.0 --http.port $((8645)) --http.corsdomain "*" \
            --metrics --metrics.addr localhost --metrics.port $((6160)) --metrics.expensive \
            --pprof --pprof.addr localhost --pprof.port $((7160)) \
            --gcmode ${gcmode} --syncmode full --monitor.maliciousvote \
            --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
            --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
            --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
            >> ${workspace}/.local/fullnode0/bsc-node.log 2>&1 &
    fi
    sleep ${sleepAfterStart}
}

function register_stakehub(){
    # wait feynman enable
    sleep 45
    for ((i = 0; i < size; i++));do
        ${workspace}/create-validator/create-validator --consensus-key-dir ${workspace}/keys/validator${i} --vote-key-dir ${workspace}/keys/bls${i} \
            --password-path ${workspace}/keys/password.txt --amount 20001 --validator-desc Val${i} --rpc-url ${RPC_URL}
    done
}

CMD=$1
ValidatorIdx=$2
case ${CMD} in
reset)
    validate_reth_config
    exit_previous
    create_validator
    prepare_bsc_client
    reset_genesis
    prepare_config
    initNetwork
    native_start
    register_stakehub
    ;;
stop)
    validate_reth_config
    exit_previous $ValidatorIdx
    ;;
start)
    validate_reth_config
    native_start $ValidatorIdx
    ;;
restart)
    validate_reth_config
    exit_previous $ValidatorIdx
    native_start $ValidatorIdx
    ;;
*)
    echo "Usage: bsc_cluster.sh | reset | stop [vidx]| start [vidx]| restart [vidx]"
    ;;
esac
