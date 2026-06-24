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

# 1. Stop any previously running geth instances
function exit_previous() {
    ValIdx=$1
    # if no geth exist just skip it
    ps -ef  | grep geth$ValIdx | grep config |awk '{print $2}' | xargs -r kill
    sleep ${sleepBeforeStart}
}

# 2. Cleanup .local and copy initial keys for validators
function create_validator() {
    rm -rf ${workspace}/.local
    mkdir -p ${workspace}/.local

    for ((i = 0; i < size; i++)); do
        cp -r ${workspace}/keys/validator${i} ${workspace}/.local/
        cp -r ${workspace}/keys/bls${i} ${workspace}/.local/
    done
}

# 3. Build bsc geth client from source if configured
function prepare_bsc_client() {
    if [ ${useLatestBscClient} = true ]; then
        if [ ! -f "${workspace}/bsc/Makefile" ]; then
            cd ${workspace}
            git clone https://github.com/bnb-chain/bsc.git
        fi
        cd ${workspace}/bsc && git pull && make geth && mv -f ${workspace}/bsc/build/bin/geth ${workspace}/bin/
    fi
}

# 4. Reset genesis submodule and install dependencies (Poetry, NPM, Forge)
# This prepares the environment for generating the genesis block
function reset_genesis() {
    if [ ! -f "${workspace}/genesis/genesis-template.json" ]; then
        cd ${workspace} && git submodule update --init --recursive genesis
        cd ${workspace}/genesis && git reset --hard ${GENESIS_COMMIT}
    fi
    cd ${workspace}/genesis

    # 1. Update the 'genesis' submodule safely
    # Backup user templates, force-update the repository to a specific 
    # compatible version ($GENESIS_COMMIT) to prevent breaking changes, 
    # and then restore the user templates.
    cp genesis-template.json genesis-template.json.bk
    cp scripts/init_holders.template scripts/init_holders.template.bk
    git stash
    cd ${workspace} && git submodule update --remote --recursive genesis && cd ${workspace}/genesis
    git reset --hard ${GENESIS_COMMIT}
    mv genesis-template.json.bk genesis-template.json
    mv scripts/init_holders.template.bk scripts/init_holders.template

    # 2. Install project-specific dependencies
    poetry install --no-root
    npm install
    
    # 3. Clean up and reinstall Foundry framework components (Standard Library & Tests)
    rm -rf lib/forge-std
    forge install --no-git foundry-rs/forge-std@v1.7.3
    cd lib/forge-std/lib
    rm -rf ds-test
    git clone https://github.com/dapphub/ds-test
}

# 5. Generate validator configurations, hardfork times, and the final genesis.json
function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf

    passedHardforkTime=$(expr $(date +%s) + ${PASSED_FORK_DELAY})
    echo "passedHardforkTime "${passedHardforkTime} > ${workspace}/.local/hardforkTime.txt
    initHolders=${INIT_HOLDER}

    # 1. Collect Validator Information & Setup Node Directories
    for ((i = 0; i < size; i++)); do
        # read their randomly generated cryptographic key files (Consensus addresses and BLS vote keys)
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
        # It assigns a massive, hardcoded amount of "voting power" (0x000001d1a94a2000) so the node has the authority to forge blocks.
        powers="0x000001d1a94a2000" #2000000000000
        mv ${workspace}/.local/bls${i}/bls ./ && rm -rf ${workspace}/.local/bls${i}
        vote_addr=0x$(cat ./bls/keystore/*json | jq .pubkey | sed 's/"//g')
        # it writes all these unique peices: the consensus address, fee collection address, voting power, and BLS vote address
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/genesis/validators.conf
        if [ ${EnableSentryNode} = true ]; then
            # Sentry nodes act as a protective firewall/proxy for Validators, 
            # hiding the Validator's real IP address from public P2P network attacks.
            mkdir -p ${workspace}/.local/sentry${i}
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        mkdir -p ${workspace}/.local/fullnode0
    fi
    rm -f ${workspace}/.local/hardforkTime.txt

    # 2. Hack / Patch the System Smart Contracts
    cd ${workspace}/genesis/
    git checkout HEAD contracts
    # "hack" the source code of the core BSCValidatorSet.sol smart contract right before compiling. 
    # They lower the turnLength and explicitly tell the system to ignore validator punishments/updates for the first 2,000 blocks to ensure your local network starts smoothly without validators instantly getting jailed.
    sed -i -e  's/alreadyInit = true;/turnLength = 16;alreadyInit = true;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    sed -i -e  's/public onlyCoinbase onlyZeroGasPrice {/public onlyCoinbase onlyZeroGasPrice {if (block.number < 2000) return;/' ${workspace}/genesis/contracts/BSCValidatorSet.sol
    
    # 3. Generate the Final Genesis Block
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
    cp genesis-dev.json genesis.json
}

# 6. Initialize the geth network for each node using the generated genesis.json
function initNetwork() {
    cd ${workspace}
    # 1. Assigning P2P Identities
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
    
    # 2. Preparing Network Arguments
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

    # 3. Generating Network Configs (config.toml)
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local --init.size=${size} --config ${workspace}/config.toml ${init_extra_args} ${workspace}/genesis/genesis.json
    rm -f ${workspace}/*bsc.log*

    # 4. Initializing the Blockchain Database (geth init)
    for ((i = 0; i < size; i++)); do
        sed -i -e '/"<nil>"/d' ${workspace}/.local/node${i}/config.toml
        # init genesis
        initLog=${workspace}/.local/node${i}/init.log
        ${workspace}/bin/geth --datadir ${workspace}/.local/node${i} init --state.scheme ${stateScheme} --db.engine ${dbEngine} ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        rm -f ${workspace}/.local/node${i}/*bsc.log*

        if [ ${EnableSentryNode} = true ]; then
            sed -i -e '/"<nil>"/d' ${workspace}/.local/sentry${i}/config.toml
            initLog=${workspace}/.local/sentry${i}/init.log
            ${workspace}/bin/geth --datadir ${workspace}/.local/sentry${i} init --state.scheme ${stateScheme} --db.engine ${dbEngine} ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
            rm -f ${workspace}/.local/sentry${i}/*bsc.log*
        fi
    done
    if [ ${EnableFullNode} = true ]; then
        sed -i -e '/"<nil>"/d' ${workspace}/.local/fullnode0/config.toml
        sed -i -e 's/EnableEVNFeatures = true/EnableEVNFeatures = false/g' ${workspace}/.local/fullnode0/config.toml
        initLog=${workspace}/.local/fullnode0/init.log
        ${workspace}/bin/geth --datadir ${workspace}/.local/fullnode0 init --state.scheme ${stateScheme} --db.engine ${dbEngine} ${workspace}/genesis/genesis.json  > "${initLog}" 2>&1
        rm -f ${workspace}/.local/fullnode0/*bsc.log*
    fi
}

function start_node() {
    local type=$1       # node | sentry | full
    local idx=$2        # index (validator/sentry)，full default 0
    local datadir=$3
    local geth_bin=$4
    local cons_addr=$5
    local http_port=$6
    local ws_port=$7
    local metrics_port=$8
    local pprof_port=$9

    # update `config` in genesis.json
    # ${workspace}/.local/node${i}/geth${i} dumpgenesis --datadir ${workspace}/.local/node${i} | jq . > ${workspace}/.local/node${i}/genesis.json
    nohup ${geth_bin} --config ${datadir}/config.toml \
        --datadir ${datadir} \
        --nodekey ${datadir}/geth/nodekey \
        --cache 512 \
        --rpc.allow-unprotected-txs --allow-insecure-unlock \
        --ws --ws.addr 0.0.0.0 --ws.port ${ws_port} \
        --http --http.addr 0.0.0.0 --http.port ${http_port} --http.corsdomain "*" \
        --metrics --metrics.addr 0.0.0.0 --metrics.port ${metrics_port} \
        --pprof --pprof.addr 0.0.0.0 --pprof.port ${pprof_port} \
        --gcmode ${gcmode} --syncmode full --monitor.maliciousvote \
        --rialtohash ${rialtoHash} \
        --override.passedforktime ${PassedForkTime} \
        --override.lorentz ${PassedForkTime} \
        --override.maxwell ${PassedForkTime} \
        --override.fermi ${PassedForkTime} \
        --override.osaka ${PassedForkTime} \
        --override.mendel ${PassedForkTime} \
        --override.pasteur ${LastHardforkTime} \
        --override.immutabilitythreshold ${FullImmutabilityThreshold} \
        --override.breatheblockinterval ${BreatheBlockInterval} \
        --override.minforblobrequest ${MinBlocksForBlobRequests} \
        --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
        $( [ "${type}" = "node" ] && echo "--mine --vote --unlock ${cons_addr} --miner.etherbase ${cons_addr} --password ${datadir}/password.txt --blspassword ${datadir}/password.txt" ) \
        >> ${datadir}/bsc-node.log 2>&1 &
}

# 7. Start the nodes (Validators, Sentry, Full) in the background
function native_start() {
    PassedForkTime=`cat ${workspace}/.local/node0/hardforkTime.txt|grep passedHardforkTime|awk -F" " '{print $NF}'`
    LastHardforkTime=$(expr ${PassedForkTime} + ${LAST_FORK_MORE_DELAY})
    rialtoHash=`cat ${workspace}/.local/node0/init.log|grep "Successfully wrote genesis state"|awk -F"hash=" '{print $NF}'|awk '{print $1}'`

    # Starting Validator Nodes
    for ((i=0; i<size; i++)); do
        datadir="${workspace}/.local/node${i}"

        # optional: ValIdx filtering
        if [ ! -z "$1" ] && [ $i -ne $1 ]; then
            continue
        fi

        # get validator address
        cons_addr="0x$(jq -r .address ${datadir}/keystore/*)"

        # Copying Geth binaries to unique names (geth0, geth1...) 
        # for easier node-specific monitoring in htop.
        cp ${workspace}/bin/geth ${datadir}/geth${i}

        base=$((8545 + i*2))
        start_node "node" $i $datadir "${datadir}/geth${i}" "${cons_addr}" \
            $base $base $((6060+i*2)) $((7060+i*2))
    done

    # Starting Sentry Nodes
    if [ ${EnableSentryNode} = true ]; then
        sleep 10
        for ((i=0; i<size; i++)); do
            datadir="${workspace}/.local/sentry${i}"
            cp ${workspace}/bin/geth ${datadir}/geth${i}

            base=$((8545 + i*2))
            start_node "sentry" $i $datadir "${datadir}/geth${i}" "" \
                $((base+1)) $((base+1)) $((6060+i*2+1)) $((7060+i*2+1))
        done
    fi

    if [ ${EnableFullNode} = true ]; then
        datadir="${workspace}/.local/fullnode0"
        cp ${workspace}/bin/geth ${datadir}/geth0

        start_node "full" 0 $datadir "${datadir}/geth0" "" \
            8645 8645 6160 7160
    fi

    sleep ${sleepAfterStart}
}

# 8. Use create-validator tool to register validator nodes on StakeHub
function register_stakehub(){
    # wait feynman enable
    sleep 45
    for ((i = 0; i < size; i++));do
        create-validator --consensus-key-dir ${workspace}/keys/validator${i} --vote-key-dir ${workspace}/keys/bls${i} \
            --password-path ${workspace}/keys/password.txt --amount 20001 --validator-desc Val${i} --rpc-url ${RPC_URL}
    done
}

# Command dispatcher
CMD=$1
ValidatorIdx=$2
case ${CMD} in
reset)
    # The 'reset' flow perform a clean initialization of the entire local cluster:
    exit_previous      # Step 1: Kill old processes
    create_validator   # Step 2: Prepare keys and .local/
    prepare_bsc_client # Step 3: Build geth if necessary
    reset_genesis      # Step 4: Setup genesis deps (Forge, Poetry, etc)
    prepare_config     # Step 5: Generate genesis.json and node configs
    initNetwork        # Step 6: Initialize Geth data directories
    native_start       # Step 7: Start the cluster nodes
    register_stakehub  # Step 8: Register validators with the network
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
