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

# stop geth client
function exit_previous() {
    ValIdx=$1
    ps -ef  | grep geth$ValIdx | grep config |awk '{print $2}' | xargs -r kill
    sleep ${sleepBeforeStart}
}

# Check if validator is a file or directory and handle accordingly
function handle_validator() {
    local validator_path=$1
    local index=$2
    local target_dir=$3
    
    if [ -f "${validator_path}" ]; then
        # It's a file containing the operator address
        echo "Validator ${index} is a file, copying operator address file"
        cp ${validator_path} ${target_dir}/
    elif [ -d "${validator_path}" ]; then
        # It's a directory containing the keystore
        echo "Validator ${index} is a directory, copying keystore directory"
        cp -r ${validator_path} ${workspace}/.local/
    else
        echo "Error: Validator ${index} is neither a file nor a directory"
        exit 1
    fi
}

function create_validator() {
    rm -rf ${workspace}/.local
    mkdir -p ${workspace}/.local

    for ((i = 0; i < size; i++)); do
        # Handle validator based on whether it's a file or directory
        handle_validator "${workspace}/keys/validator${i}" ${i} "${workspace}/.local/validator${i}"
        cp -r ${workspace}/keys/consensus${i} ${workspace}/.local/
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
    fi
}

function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf

    passedHardforkTime=$(expr $(date +%s) + ${PASSED_FORK_DELAY})
    echo "passedHardforkTime "${passedHardforkTime} > ${workspace}/.local/hardforkTime.txt
    initHolders=${INIT_HOLDER}
    for ((i = 0; i < size; i++)); do
        # Check if validator is a file or directory and extract operator address accordingly
        if [ -f "${workspace}/keys/validator${i}" ]; then
            # Read operator address from the file
            operator_addr=$(cat ${workspace}/keys/validator${i})
        elif [ -d "${workspace}/keys/validator${i}" ]; then
            # Extract operator address from keystore
            for f in ${workspace}/keys/validator${i}/keystore/*; do
                operator_addr="0x$(cat ${f} | jq -r .address)"
            done
        else
            echo "Error: Validator ${i} is neither a file nor a directory"
            exit 1
        fi
        
        initHolders=${initHolders}","${operator_addr}
        fee_addr=${operator_addr}

        for f in ${workspace}/.local/consensus${i}/keystore/*; do
            cons_addr="0x$(cat ${f} | jq -r .address)"
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
        
        # Handle validator based on whether it's a file or directory
        if [ -d "${workspace}/.local/validator${i}" ]; then
            # Old format: validator is a directory with keystore
            mv ${workspace}/.local/validator${i}/keystore ${workspace}/.local/node${i}/ && rm -rf ${workspace}/.local/validator${i}
        else
            # New format: validator is a file with operator address
            # In this case, we don't need to move anything to node directory
            rm -rf ${workspace}/.local/validator${i}
        fi
        
        mv ${workspace}/.local/consensus${i}/keystore ${workspace}/.local/node${i}/ && rm -rf ${workspace}/.local/consensus${i}
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
        elif  [ $i -eq 1 ] ; then
            ${workspace}/bin/geth --datadir ${workspace}/.local/node${i} init --state.scheme path --db.engine pebble --multidatabase ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
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
            --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
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
                --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
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
            --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
            --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
            >> ${workspace}/.local/fullnode0/bsc-node.log 2>&1 &
    fi
    sleep ${sleepAfterStart}
}

function register_stakehub(){
    if [ -f "${workspace}/keys/validator${i}" ];then
        exit 1
    fi
    # wait feynman enable
    sleep 45
    for ((i = 0; i < size; i++));do
        ${workspace}/create-validator/create-validator --operator-key-dir ${workspace}/keys/validator${i} --consensus-key-dir ${workspace}/keys/consensus${i} --vote-key-dir ${workspace}/keys/bls${i} \
            --password-path ${workspace}/keys/password.txt --amount 20001 --validator-desc Val${i} --rpc-url ${RPC_URL}
    done
}

CMD=$1
ValidatorIdx=$2
case ${CMD} in
reset)
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
    exit_previous $ValidatorIdx
    ;;
start)
    native_start $ValidatorIdx
    ;;
restart)
    exit_previous $ValidatorIdx
    native_start $ValidatorIdx
    ;;
regen-genesis)
    create_validator
    reset_genesis
    prepare_config
    ;;
*)
    echo "Usage: bsc_cluster.sh | reset | stop [vidx]| start [vidx]| restart [vidx] | regen-genesis"
    ;;
esac