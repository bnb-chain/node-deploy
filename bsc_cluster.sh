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
epoch=200
blockInterval=3
sleepBeforeStart=10

# stop geth client
function exit_previous() {
    ValIdx=$1
    ps -ef  | grep geth$ValIdx | grep config |awk '{print $2}' | xargs kill
    sleep ${sleepBeforeStart}
}

function create_validator() {
    rm -rf ${workspace}/.local
    mkdir -p ${workspace}/.local/bsc

    for ((i = 0; i < size; i++)); do
        cp -r ${workspace}/keys/validator${i} ${workspace}/.local/bsc/
        cp -r ${workspace}/keys/bls${i} ${workspace}/.local/bsc/
    done
}

# reset genesis, but keep edited genesis-template.json
function reset_genesis() {
    if [ ! -f "${workspace}/genesis/genesis-template.json" ]; then
        cd ${workspace} && git submodule update --init --recursive && cd ${workspace}/genesis
        git reset --hard ${GENESIS_COMMIT}
    fi
    cd ${workspace}/genesis
    cp genesis-template.json genesis-template.json.bk
    git stash
    cd ${workspace} && git submodule update --remote --recursive && cd ${workspace}/genesis
    git reset --hard ${GENESIS_COMMIT}
    mv genesis-template.json.bk genesis-template.json

    poetry install --no-root
    npm install
    rm -rf lib/forge-std
    forge install --no-git --no-commit foundry-rs/forge-std@v1.7.3
    cd lib/forge-std/lib
    rm -rf ds-test
    git clone https://github.com/dapphub/ds-test
}

function prepare_bsc_client() {
    if [ ${useLatestBscClient} = true ]; then
        if [ ! -d "${workspace}/bsc" ]; then
            cd ${workspace} && git submodule add https://github.com/bnb-chain/bsc.git bsc
        fi
        cd ${workspace}/bsc && make geth && mkdir -p ${workspace}/bin && mv -f ${workspace}/bsc/build/bin/geth ${workspace}/bin/geth
    fi
}

function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf

    passedHardforkTime=$(expr $(date +%s) + ${PASSED_FORK_DELAY})
    echo "passedHardforkTime "${passedHardforkTime} > ${workspace}/.local/bsc/hardforkTime.txt
    initHolders=${INIT_HOLDER}
    for ((i = 0; i < size; i++)); do
        for f in ${workspace}/.local/bsc/validator${i}/keystore/*; do
            cons_addr="0x$(cat ${f} | jq -r .address)"
            initHolders=${initHolders}","${cons_addr}
            fee_addr=${cons_addr}
        done

        mkdir -p ${workspace}/.local/bsc/node${i}
        if [ ${EnableSentryNode} = true ]; then
            mkdir -p ${workspace}/.local/bsc/sentry${i}
        fi
        cp ${workspace}/keys/password.txt ${workspace}/.local/bsc/node${i}/
        cp ${workspace}/.local/bsc/hardforkTime.txt ${workspace}/.local/bsc/node${i}/
        bbcfee_addrs=${fee_addr}
        powers="0x000001d1a94a2000" #2000000000000
        mv ${workspace}/.local/bsc/bls${i}/bls ${workspace}/.local/bsc/node${i}/ && rm -rf ${workspace}/.local/bsc/bls${i}
        vote_addr=0x$(cat ${workspace}/.local/bsc/node${i}/bls/keystore/*json | jq .pubkey | sed 's/"//g')
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/genesis/validators.conf
        echo "validator" ${i} ":" ${cons_addr}
        echo "validatorFee" ${i} ":" ${fee_addr}
        echo "validatorVote" ${i} ":" ${vote_addr}
    done
    rm -f ${workspace}/.local/bsc/hardforkTime.txt

    cd ${workspace}/genesis/
    git checkout HEAD contracts

    sed -i -e '/registeredContractChannelMap\[VALIDATOR_CONTRACT_ADDR\]\[STAKING_CHANNELID\]/d' ${workspace}/genesis/contracts/deprecated/CrossChain.sol
    sed -i -e  's/alreadyInit = true;/turnLength = 4;alreadyInit = true;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    sed -i -e  's/public onlyCoinbase onlyZeroGasPrice {/public onlyCoinbase onlyZeroGasPrice {if (block.number < 30) return;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    
    poetry run python -m scripts.generate generate-validators
    poetry run python -m scripts.generate generate-init-holders "${initHolders}"
    poetry run python -m scripts.generate dev \
      --epoch ${epoch} \
      --init-felony-slash-scope "60" \
      --breathe-block-interval "10 minutes" \
      --block-interval ${blockInterval} \
      --stake-hub-protector "${INIT_HOLDER}" \
      --unbond-period "2 minutes" \
      --downtime-jail-time "2 minutes" \
      --felony-jail-time "3 minutes" \
      --init-voting-delay "1 minutes / BLOCK_INTERVAL" \
      --init-voting-period "2 minutes / BLOCK_INTERVAL" \
      --init-min-period-after-quorum "uint64(1 minutes / BLOCK_INTERVAL)" \
      --governor-protector "${INIT_HOLDER}" \
      --init-minimal-delay "1 minutes"
}

function initNetwork() {
    cd ${workspace}
    for ((i = 0; i < size; i++)); do
        mkdir ${workspace}/.local/bsc/node${i}/geth
        cp ${workspace}/keys/validator-nodekey${i} ${workspace}/.local/bsc/node${i}/geth/nodekey
        if [ ${EnableSentryNode} = true ]; then
            mkdir ${workspace}/.local/bsc/sentry${i}/geth
            cp ${workspace}/keys/sentry-nodekey${i} ${workspace}/.local/bsc/sentry${i}/geth/nodekey
        fi
    done
    
    init_extra_args=""
    if [ ${EnableSentryNode} = true ]; then
        init_extra_args="--init.sentrynode"
    fi
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc --init.size=${size} --config ${workspace}/config.toml ${init_extra_args} ${workspace}/genesis/genesis.json
    rm -f ${workspace}/*bsc.log*
    for ((i = 0; i < size; i++)); do
        sed -i -e '/"<nil>"/d' ${workspace}/.local/bsc/node${i}/config.toml
        mv ${workspace}/.local/bsc/validator${i}/keystore ${workspace}/.local/bsc/node${i}/ && rm -rf ${workspace}/.local/bsc/validator${i}

        cp ${workspace}/bin/geth ${workspace}/.local/bsc/node${i}/geth${i}
        # init genesis
        initLog=${workspace}/.local/bsc/node${i}/init.log
        if  [ $i -eq 0 ] ; then
                ${workspace}/bin/geth --datadir ${workspace}/.local/bsc/node${i} init --state.scheme ${stateScheme} --db.engine ${dbEngine} ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        elif  [ $i -eq 1 ] ; then
            ${workspace}/bin/geth --datadir ${workspace}/.local/bsc/node${i} init --state.scheme path --db.engine pebble --multidatabase ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        else
            ${workspace}/bin/geth --datadir ${workspace}/.local/bsc/node${i} init --state.scheme path --db.engine pebble ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        fi
        rm -f ${workspace}/.local/bsc/node${i}/*bsc.log*

        if [ ${EnableSentryNode} = true ]; then
            sed -i -e '/"<nil>"/d' ${workspace}/.local/bsc/sentry${i}/config.toml
            cp ${workspace}/bin/geth ${workspace}/.local/bsc/sentry${i}/geth${i}
            initLog=${workspace}/.local/bsc/sentry${i}/init.log
            ${workspace}/bin/geth --datadir ${workspace}/.local/bsc/sentry${i} init --state.scheme path --db.engine pebble ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
            rm -f ${workspace}/.local/bsc/sentry${i}/*bsc.log*
        fi
    done
}

function native_start() {
    PassedForkTime=`cat ${workspace}/.local/bsc/node0/hardforkTime.txt|grep passedHardforkTime|awk -F" " '{print $NF}'`
    LastHardforkTime=$(expr ${PassedForkTime} + ${LAST_FORK_MORE_DELAY})

    ValIdx=$1
    for ((i = 0; i < size; i++));do
        if [ ! -z $ValIdx ] && [ $i -ne $ValIdx ]; then
            continue
        fi

        for j in ${workspace}/.local/bsc/node${i}/keystore/*;do
            cons_addr="0x$(cat ${j} | jq -r .address)"
        done

        HTTPPort=$((8545 + i*2))
        WSPort=${HTTPPort}
        MetricsPort=$((6060 + i*2))
        PProfPort=$((7060 + i*2))
 
        # geth may be replaced
        rm -f ${workspace}/.local/bsc/node${i}/geth${i}
        cp ${workspace}/bin/geth ${workspace}/.local/bsc/node${i}/geth${i}

        if [ ${EnableSentryNode} = true ]; then
            rm -f ${workspace}/.local/bsc/sentry${i}/geth${i} && cp ${workspace}/bin/geth ${workspace}/.local/bsc/sentry${i}/geth${i}
        fi

        initLog=${workspace}/.local/bsc/node${i}/init.log
        rialtoHash=`cat ${initLog}|grep "database=chaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`

        # update `config` in genesis.json
        ${workspace}/.local/bsc/node${i}/geth${i} dumpgenesis --datadir ${workspace}/.local/bsc/node${i} | jq . > ${workspace}/.local/bsc/node${i}/genesis.json

        # run BSC node
        nohup  ${workspace}/.local/bsc/node${i}/geth${i} --config ${workspace}/.local/bsc/node${i}/config.toml \
            --datadir ${workspace}/.local/bsc/node${i} \
            --password ${workspace}/.local/bsc/node${i}/password.txt \
            --blspassword ${workspace}/.local/bsc/node${i}/password.txt \
            --nodekey ${workspace}/.local/bsc/node${i}/geth/nodekey \
            --unlock ${cons_addr} --miner.etherbase ${cons_addr} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
            --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
            --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
            --pprof --pprof.addr localhost --pprof.port ${PProfPort} \
            --gcmode ${gcmode} --syncmode full --mine --vote --monitor.maliciousvote \
            --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
            --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
            --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
            > ${workspace}/.local/bsc/node${i}/bsc-node.log 2>&1 &
        

        if [ ${EnableSentryNode} = true ]; then
            nohup  ${workspace}/.local/bsc/sentry${i}/geth${i} --config ${workspace}/.local/bsc/sentry${i}/config.toml \
                --datadir ${workspace}/.local/bsc/sentry${i} \
                --nodekey ${workspace}/.local/bsc/sentry${i}/geth/nodekey \
                --rpc.allow-unprotected-txs --allow-insecure-unlock  \
                --ws.addr 0.0.0.0 --ws.port $((WSPort+1)) --http.addr 0.0.0.0 --http.port $((HTTPPort+1)) --http.corsdomain "*" \
                --metrics --metrics.addr localhost --metrics.port $((MetricsPort+1)) --metrics.expensive \
                --pprof --pprof.addr localhost --pprof.port $((PProfPort+1)) \
                --gcmode ${gcmode} --syncmode full \
                --rialtohash ${rialtoHash} --override.passedforktime ${PassedForkTime} --override.lorentz ${PassedForkTime} --override.maxwell ${LastHardforkTime} \
                --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
                --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
                > ${workspace}/.local/bsc/sentry${i}/bsc-node.log 2>&1 &
        fi
    done
}

function register_stakehub(){
    echo "sleep 45s to wait feynman enable"
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
    exit_previous
    create_validator
    prepare_bsc_client
    reset_genesis
    prepare_config
    initNetwork
    native_start
    register_stakehub
    # to prevent stuck
    exit_previous
    native_start
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
*)
    echo "Usage: bsc_cluster.sh | reset | stop [vidx]| start [vidx]| restart [vidx]"
    ;;
esac
