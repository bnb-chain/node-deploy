#!/usr/bin/env bash

# Exit script on error
set -e

basedir=$(
    cd $(dirname $0)
    pwd
)
workspace=${basedir}
source ${workspace}/.env
source ${workspace}/qa-env-resource/machines_meta.sh # including machine ips and ids, don't upload!!!
validator_ips=(${validator_ips_comma//,/ })
size=${#validator_ips[@]}
stateScheme="hash"
dbEngine="leveldb"
gcmode="full"
sleepBeforeStart=15
sleepAfterStart=10
copyDir="bsc-qa"

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

    # poetry install --no-root
    npm install
    rm -rf lib/forge-std
    forge install --no-git foundry-rs/forge-std@v1.7.3
    cd lib/forge-std/lib
    rm -rf ds-test
    git clone https://github.com/dapphub/ds-test
}

function prepare_config() {
    \cp -f ${RETH_BSC_BINARY_PATH} ${workspace}/bin/reth-bsc
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
        cp ${workspace}/qa-env-resource/* ./ && rm -f *upgrade-single*
        bbcfee_addrs=${fee_addr}
        powers="0x000001d1a94a2000" #2000000000000
        mv ${workspace}/.local/bls${i}/bls ./ && rm -rf ${workspace}/.local/bls${i}
        vote_addr=0x$(cat ./bls/keystore/*json | jq .pubkey | sed 's/"//g')
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/genesis/validators.conf

        # Handle reth-bsc for first RETH_NODE_COUNT nodes, geth for others
        if [ $i -lt $RETH_NODE_COUNT ]; then
            sed -i -e "s/KEYPASS=\"123456\"/KEYPASS=\"${KEYPASS}\"/g" reth-bsc-chaind.sh
            if [ ${EnableSentryNode} = true ]; then
                targetDir=${workspace}/.local/sentry${i}
                mkdir -p ${targetDir} && cd ${targetDir}
                cp ${workspace}/.local/hardforkTime.txt ./
                cp ${workspace}/qa-env-resource/* ./ && rm -f *upgrade-single*
                sed -i -e "s/KEYPASS=\"123456\"/KEYPASS=\"${KEYPASS}\"/g" reth-bsc-chaind.sh
                sed -i -e 's/ENABLE_MINING=true/ENABLE_MINING=false/g' reth-bsc-chaind.sh
                sed -i -e 's/workdir="validator"/workdir="sentry"/g' reth-bsc-chaind.sh
                sed -i -e 's/bin="reth-bsc"/bin="reth-bsc-sentry"/g' reth-bsc-chaind.sh
                sed -i -e 's/portInc=0/portInc=2/g' reth-bsc-chaind.sh
                sed -i -e 's/auth_port=8551/auth_port=8552/g' reth-bsc-chaind.sh
                rm -f reth-bsc-chaind.sh.bak
                sed -i -e 's/workdir="validator"/workdir="sentry"/g' reth-bsc-init.sh
                sed -i -e 's/bin="reth-bsc"/bin="reth-bsc-sentry"/g' reth-bsc-init.sh
                rm -f reth-bsc-init.sh.bak
                mv reth-bsc.service reth-bsc-sentry.service
                sed -i -e 's/validator/sentry/g' reth-bsc-sentry.service
                sed -i -e 's/Description=reth-bsc/Description=reth-bsc-sentry/g' reth-bsc-sentry.service
                rm -f reth-bsc-sentry.service.bak
            fi
        else
            sed -i -e "s/{{validatorAddr}}/${cons_addr}/g"  chaind.sh && rm -f chaind.sh.bak
            if [ ${EnableSentryNode} = true ]; then
                targetDir=${workspace}/.local/sentry${i}
                mkdir -p ${targetDir} && cd ${targetDir}
                cp ${workspace}/.local/hardforkTime.txt ./
                cp ${workspace}/qa-env-resource/* ./ && rm -f *upgrade-single*
                sed -i -e '/--mine/d' chaind.sh
                sed -i -e 's/workdir="validator"/workdir="sentry"/g' chaind.sh
                sed -i -e 's/bin="bsc"/bin="sentry"/g' chaind.sh
                sed -i -e "s/portInc=0/portInc=2/g" chaind.sh
                rm -f chaind.sh.bak
                sed -i -e 's/workdir="validator"/workdir="sentry"/g' init.sh
                sed -i -e 's/bin="bsc"/bin="sentry"/g' init.sh
                rm -f init.sh.bak
                mv bsc.service sentry.service
                sed -i -e 's/validator/sentry/g' sentry.service
                sed -i -e 's/bsc/sentry/g' sentry.service
                rm -f sentry.service.bak
            fi
        fi

    done
    if [ ${EnableFullNode} = true ]; then
        targetDir=${workspace}/.local/fullnode0
        mkdir -p ${targetDir} && cd ${targetDir}
        cp ${workspace}/.local/hardforkTime.txt ./
        cp ${workspace}/qa-env-resource/* ./ && rm -f upgrade-single*
        sed -i -e '/--mine/d' chaind.sh && rm -f chaind.sh.bak
    fi
    rm -f ${workspace}/.local/hardforkTime.txt

    cd ${workspace}/genesis/
    git checkout HEAD contracts
    sed -i -e  's/alreadyInit = true;/turnLength = 16;alreadyInit = true;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    sed -i -e  's/public onlyCoinbase onlyZeroGasPrice {/public onlyCoinbase onlyZeroGasPrice {if (block.number < 300) return;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol

    python3 -m scripts.generate generate-validators
    python3 -m scripts.generate generate-init-holders "${initHolders}"
    python3 -m scripts.generate dev \
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
    #cp genesis-dev.json genesis.json
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
        init_extra_args="--init.sentrynode-size ${size} --init.sentrynode-ips ${sentry_ips_comma}"
    fi
    if [ ${EnableFullNode} = true ]; then
        init_extra_args="${init_extra_args} --init.fullnode-size 1 --init.fullnode-ips ${fullnode_ips_comma}"
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
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local --init.size=${size} --init.ips "${validator_ips_comma}" --config ${workspace}/qa-env-resource/config.toml ${init_extra_args} ${workspace}/genesis/genesis.json
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
            sed -i -e 's/:30311/:30611/g' ${workspace}/.local/node${i}/config.toml
            sed -i -e 's/:30411/:30311/g' ${workspace}/.local/node${i}/config.toml

            sed -i -e '/"<nil>"/d' ${workspace}/.local/sentry${i}/config.toml
            sed -i -e 's/:30311/:30611/g' ${workspace}/.local/sentry${i}/config.toml
            sed -i -e 's/:30411/:30311/g' ${workspace}/.local/sentry${i}/config.toml
            initLog=${workspace}/.local/sentry${i}/init.log
            ${workspace}/bin/geth --datadir ${workspace}/.local/sentry${i} init --state.scheme path --db.engine pebble ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
            rm -f ${workspace}/.local/sentry${i}/*bsc.log*
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        sed -i -e '/"<nil>"/d' ${workspace}/.local/fullnode0/config.toml
        sed -i -e 's/:30311/:30611/g' ${workspace}/.local/fullnode0/config.toml
        sed -i -e 's/:30411/:30311/g' ${workspace}/.local/fullnode0/config.toml
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

    if [ ${EnableSentryNode} = true ]; then
        cp ${workspace}/.local/node${nodeIndex}/genesis_reth.json ${workspace}/.local/sentry${nodeIndex}/genesis_reth.json
    fi
    
    # Get the first bootnode enode from BootstrapNodes configuration
    # Extract the complete first bootnode entry (including the full enode:// URL)
    bootnode_enode=$(grep -E "BootstrapNodes" ${workspace}/.local/node${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
    staic_enode=$(grep -E "StaticNodes" ${workspace}/.local/node${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
    
    # Extract discovery port from the current node's config.toml ListenAddr
    discovery_port=$(grep "ListenAddr" ${workspace}/.local/node${nodeIndex}/config.toml | sed 's/.*:\([0-9]*\).*/\1/')
    auth_port=8551
    
    # Detect keystore path dynamically
    keystore_path=$(find ${workspace}/.local/node${nodeIndex}/keystore -name "UTC--*" -type f | head -1)
    nodekey_path=$(find ${workspace}/.local/node${nodeIndex}/geth/nodekey -type f | head -1)
    peer_conf=()
    if [ -n "${bootnode_enode}" ]; then
        peer_conf+=(--bootnodes ${bootnode_enode})
    fi
    if [ -n "${staic_enode}" ]; then
        peer_conf+=(--trusted-peers ${staic_enode})
    fi

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

    evn_conf=()
    if [ ${EnableSentryNode} = true ]; then
        evn_conf+=(--evn.enabled)
        add_nodeid=$(grep -E "EVNNodeIDsToAdd" ${workspace}/.local/node${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${add_nodeid}" ]; then
            evn_conf+=(--evn.add-nodeid ${add_nodeid})
        fi
        remove_nodeid=$(grep -E "EVNNodeIDsToRemove" ${workspace}/.local/node${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${remove_nodeid}" ]; then
            evn_conf+=(--evn.remove-nodeid ${remove_nodeid})
        fi
    fi
    echo "node${nodeIndex}, nodekey_path: ${nodekey_path}, peer_conf: ${peer_conf[@]}, evn_conf: ${evn_conf[@]}"
    
    # Run reth-bsc node
    nohup env RUST_LOG=trace BREATHE_BLOCK_INTERVAL=${BreatheBlockInterval} ${RETH_BSC_BINARY_PATH} node \
        --chain ${workspace}/.local/node${nodeIndex}/genesis_reth.json \
        --datadir ${workspace}/.local/node${nodeIndex} \
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
        --mining.enabled \
        --mining.keystore-path ${keystore_path} \
        --mining.keystore-password ${KEYPASS} "${bls_cli_args[@]}" \
        --log.stdout.format log-fmt \
        >> ${workspace}/.local/node${nodeIndex}/reth.log 2>&1 &
    
    if [ ${EnableSentryNode} = true ]; then
        discovery_port=$(grep "ListenAddr" ${workspace}/.local/sentry${nodeIndex}/config.toml | sed 's/.*:\([0-9]*\).*/\1/')
        nodekey_path=$(find ${workspace}/.local/sentry${i}/geth/nodekey -type f | head -1)
        bootnode_enode=$(grep -E "BootstrapNodes" ${workspace}/.local/sentry${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        staic_enode=$(grep -E "StaticNodes" ${workspace}/.local/sentry${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        peer_conf=()
        if [ -n "${bootnode_enode}" ]; then
            peer_conf+=(--bootnodes ${bootnode_enode})
        fi
        if [ -n "${staic_enode}" ]; then
            peer_conf+=(--trusted-peers ${staic_enode})
        fi
        evn_conf=()
        evn_conf+=(--evn.enabled)
        whitelist_nodeid=$(grep -E "EVNNodeIdsWhitelist" ${workspace}/.local/sentry${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${whitelist_nodeid}" ]; then
            evn_conf+=(--evn.whitelist-nodeids ${whitelist_nodeid})
        fi
        proxyed_val=$(grep -E "ProxyedValidatorAddresses" ${workspace}/.local/sentry${nodeIndex}/config.toml | grep -o '\[".*"\]' | sed 's/\["//;s/"\]//;s/", "/,/g')
        if [ -n "${proxyed_val}" ]; then
            evn_conf+=(--evn.proxyed-validator ${proxyed_val})
        fi

        echo "sentry${nodeIndex}, nodekey_path: ${nodekey_path}, peer_conf: ${peer_conf[@]}, evn_conf: ${evn_conf[@]}"
        nohup env RUST_LOG=trace BREATHE_BLOCK_INTERVAL=${BreatheBlockInterval} ${RETH_BSC_BINARY_PATH} node \
            --chain ${workspace}/.local/sentry${nodeIndex}/genesis_reth.json \
            --datadir ${workspace}/.local/sentry${nodeIndex} \
            --genesis-hash ${rialtoHash} \
            --http \
            --http.addr 0.0.0.0 \
            --http.port $((HTTPPort+1)) \
            --p2p-secret-key ${nodekey_path} \
            --ws \
            --ws.addr 0.0.0.0 \
            --ws.port $((WSPort+1)) \
            --discovery.addr 0.0.0.0 \
            --discovery.port ${discovery_port} \
            --authrpc.port $((auth_port+1)) \
            --port ${discovery_port} \
            ${peer_conf[@]} \
            ${evn_conf[@]} \
            --log.stdout.format log-fmt \
            >> ${workspace}/.local/sentry${nodeIndex}/reth.log 2>&1 &
    fi
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
            # TODO: there are not supported flags, may support later
            # --override.breatheblockinterval --override.minforblobrequest --MetricsPort
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
    sleep 100
    for ((i = 0; i < size; i++));do
        ${workspace}/create-validator/create-validator --consensus-key-dir ${workspace}/keys/validator${i} --vote-key-dir ${workspace}/keys/bls${i} \
            --password-path ${workspace}/keys/password.txt --amount 20001 --validator-desc Val${i} --rpc-url ${RPC_URL}
    done
}

function remote_reset_config() {
    rm -rf /mnt/efs/${copyDir}/clusterNetwork
    cp -r ${workspace}/.local /mnt/efs/${copyDir}/clusterNetwork
    ips=(${validator_ips_comma//,/ })
    for ((i=0;i<${#ips[@]};i++));do
        dst_id=${ips2ids[${ips[i]}]}
        echo "reset config for node${i}, id: ${ips[i]}, dst_id: ${dst_id}"
        # Handle reth-bsc for first RETH_NODE_COUNT nodes, geth for others
        if [ $i -lt $RETH_NODE_COUNT ]; then
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/sentry${i}/config.toml /server/sentry/"
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/sentry${i}/reth-bsc-chaind.sh /server/sentry/"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/node${i}/config.toml /server/validator/"
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/node${i}/reth-bsc-chaind.sh /server/validator/"
        else
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/sentry${i}/config.toml /server/sentry/"
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/sentry${i}/chaind.sh /server/sentry/"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/node${i}/config.toml /server/validator/"
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/node${i}/chaind.sh /server/validator/"
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        fullnode_ips=(${fullnode_ips_comma//,/ })
        dst_id=${ips2ids[${fullnode_ips[0]}]}
        aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/fullnode0/config.toml /server/validator/"
	    aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo \cp -f /mnt/efs/${copyDir}/clusterNetwork/fullnode0/chaind.sh /server/validator/"
    fi
}

function remote_start() {
    rm -rf /mnt/efs/${copyDir}/clusterNetwork
    cp -r ${workspace}/.local /mnt/efs/${copyDir}/clusterNetwork
    for dst_id in ${ips2ids[@]}; do
        echo "start node${i}, dst_id: ${dst_id}"
        # Handle reth-bsc for first RETH_NODE_COUNT nodes, geth for others
        if [ $i -lt $RETH_NODE_COUNT ]; then
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo service reth-bsc-sentry stop"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo service reth-bsc stop"
        else
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo service sentry stop"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo service bsc stop"
        fi
    done
    sleep 100
    cp ${workspace}/bin/geth /mnt/efs/${copyDir}/clusterNetwork/
    cp ${workspace}/bin/reth-bsc /mnt/efs/${copyDir}/clusterNetwork/
    ips=(${validator_ips_comma//,/ })
    for ((i=0;i<${#ips[@]};i++));do
        dst_id=${ips2ids[${ips[i]}]}
        echo "start for node${i}, id: ${ips[i]}, dst_id: ${dst_id}"
        # Handle reth-bsc for first RETH_NODE_COUNT nodes, geth for others
        if [ $i -lt $RETH_NODE_COUNT ]; then
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/reth-bsc /tmp/reth-bsc && sudo bash -x /mnt/efs/${copyDir}/clusterNetwork/sentry${i}/reth-bsc-init.sh"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/reth-bsc /tmp/reth-bsc && sudo bash -x /mnt/efs/${copyDir}/clusterNetwork/node${i}/reth-bsc-init.sh"
        else
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/geth /tmp/geth && sudo bash -x /mnt/efs/${copyDir}/clusterNetwork/sentry${i}/init.sh"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/geth /tmp/geth && sudo bash -x /mnt/efs/${copyDir}/clusterNetwork/node${i}/init.sh"
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        fullnode_ips=(${fullnode_ips_comma//,/ })
        dst_id=${ips2ids[${fullnode_ips[0]}]}
        aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/geth /tmp/geth && sudo bash -x /mnt/efs/${copyDir}/clusterNetwork/fullnode0/init.sh"
    fi
}

function remote_upgrade() {
    cp ${workspace}/bin/geth /mnt/efs/${copyDir}/clusterNetwork/
    if [ ${EnableSentryNode} = true ]; then
        cp ${workspace}/qa-env-resource/upgrade-single-sentry.sh /mnt/efs/${copyDir}/clusterNetwork/
        cp ${workspace}/qa-env-resource/reth-bsc-upgrade-single-sentry.sh /mnt/efs/${copyDir}/clusterNetwork/
    fi
    cp ${workspace}/qa-env-resource/upgrade-single-validator.sh /mnt/efs/${copyDir}/clusterNetwork/
    cp ${workspace}/qa-env-resource/reth-bsc-upgrade-single-validator.sh /mnt/efs/${copyDir}/clusterNetwork/
    for dst_id in ${ips2ids[@]}; do
        echo "upgrade config for node${i}, dst_id: ${dst_id}"
        # Handle reth-bsc for first RETH_NODE_COUNT nodes, geth for others
        if [ $i -lt $RETH_NODE_COUNT ]; then
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/reth-bsc /tmp/reth-bsc && sudo cp /mnt/efs/${copyDir}/clusterNetwork/reth-bsc-upgrade-single-sentry.sh /tmp/ && sudo bash -x /tmp/reth-bsc-upgrade-single-sentry.sh"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript"   --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/reth-bsc /tmp/reth-bsc && sudo cp /mnt/efs/${copyDir}/clusterNetwork/reth-bsc-upgrade-single-validator.sh /tmp/ && sudo bash -x /tmp/reth-bsc-upgrade-single-validator.sh"
        else
            if [ ${EnableSentryNode} = true ]; then
                aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript" \
                --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/geth /tmp/geth && sudo cp /mnt/efs/${copyDir}/clusterNetwork/upgrade-single-sentry.sh /tmp/ && sudo bash -x /tmp/upgrade-single-sentry.sh"
            fi
            aws ssm send-command --instance-ids "${dst_id}" --document-name "AWS-RunShellScript" \
                --parameters commands="sudo cp /mnt/efs/${copyDir}/clusterNetwork/geth /tmp/geth && sudo cp /mnt/efs/${copyDir}/clusterNetwork/upgrade-single-validator.sh /tmp/ && sudo bash -x /tmp/upgrade-single-validator.sh"
        fi
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
remote_reset)
    create_validator
    reset_genesis
    prepare_config
    initNetwork
    remote_start
    # to prevent stuck
    remote_upgrade
    register_stakehub
    ;;
remote_reset_config)
    create_validator
    reset_genesis
    prepare_config
    initNetwork
    remote_reset_config
    ;;
remote_upgrade)
    remote_upgrade
    ;;
*)
    echo "Usage: bsc_cluster.sh | reset | stop [vidx]| start [vidx]| restart [vidx]| remote_reset | remote_upgrade"
    ;;
esac
