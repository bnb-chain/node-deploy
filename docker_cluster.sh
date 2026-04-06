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

# 1. Cleanup .local and copy initial keys for validators
function create_validator() {
    rm -rf ${workspace}/.local
    mkdir -p ${workspace}/.local

    for ((i = 0; i < size; i++)); do
        cp -r ${workspace}/keys/validator${i} ${workspace}/.local/
        cp -r ${workspace}/keys/bls${i} ${workspace}/.local/
    done
}

# 2. Build bsc geth client from source if configured
function prepare_bsc_client() {
    if [ ${useLatestBscClient} = true ]; then
        if [ ! -f "${workspace}/bsc/Makefile" ]; then
            cd ${workspace}
            git clone https://github.com/bnb-chain/bsc.git
        fi
        cd ${workspace}/bsc && git pull && make geth && cp -f ${workspace}/bsc/build/bin/geth ${workspace}/bin/
    fi
}

# 3. Reset genesis submodule and install dependencies (Poetry, NPM, Forge)
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

# 4. Generate validator configurations, hardfork times, and the final genesis.json
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

# 5. Initialize the geth network for each node using the generated genesis.json
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

# 6. Patch P2P network to use Docker DNS instead of localhost
function patch_p2p_network() {
    # Replace 127.0.0.1 IPs in config.toml with docker-compose service names
    for ((i=0; i<size; i++)); do
        p2p_port=$((30311 + i))
        if [ -f "${workspace}/.local/node${i}/config.toml" ]; then
            # Replace localhost representation of this node's P2P endpoint in ALL configs
            find ${workspace}/.local -name "config.toml" -type f -exec sed -i -e "s/127.0.0.1:${p2p_port}/bsc-node-${i}:${p2p_port}/g" {} \;
        fi
    done

    # Handle sentry
    if [ ${EnableSentryNode} = true ]; then
        for ((i=0; i<size; i++)); do
            p2p_port=$((30411 + i))
            find ${workspace}/.local -name "config.toml" -type f -exec sed -i -e "s/127.0.0.1:${p2p_port}/bsc-sentry-${i}:${p2p_port}/g" {} \;
        done
    fi

    # Handle fullnode
    if [ ${EnableFullNode} = true ]; then
        p2p_port=30511
        find ${workspace}/.local -name "config.toml" -type f -exec sed -i -e "s/127.0.0.1:${p2p_port}/bsc-fullnode-0:${p2p_port}/g" {} \;
    fi

    # Force Geth to output to STDOUT instead of file by removing the default FilePath config
    find ${workspace}/.local -name "config.toml" -type f -exec sed -i -e '/FilePath/d' {} \;
}

# 7. Extract variables and generate docker-compose file
function generate_compose() {
    PassedForkTime=$(cat ${workspace}/.local/node0/hardforkTime.txt|grep passedHardforkTime|awk -F" " '{print $NF}')
    LastHardforkTime=$(expr ${PassedForkTime} + ${LAST_FORK_MORE_DELAY})
    rialtoHash=$(cat ${workspace}/.local/node0/init.log|grep "database=chaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}')

    echo "Generating .env.cluster..."
    cat <<EOF > ${workspace}/.env.cluster
RIALTO_HASH=${rialtoHash}
PASSED_FORK_TIME=${PassedForkTime}
LAST_HARDFORK_TIME=${LastHardforkTime}
FULL_IMMUTABILITY_THRESHOLD=${FullImmutabilityThreshold}
BREATHE_BLOCK_INTERVAL=${BreatheBlockInterval}
MIN_FOR_BLOB_REQUESTS=${MinBlocksForBlobRequests}
DEFAULT_EXTRA_RESERVE=${DefaultExtraReserveForBlobRequests}
EOF

    COMPOSE_FILE=${workspace}/docker-compose.cluster.yml
    echo "Generating ${COMPOSE_FILE}..."
    echo "services:" > $COMPOSE_FILE

    # Validators
    for ((i=0; i<size; i++)); do
        base_rpc=$((8545 + i*2))
        base_metrics=$((6060 + i*2))
        base_pprof=$((7060 + i*2))
        p2p_port=$((30311 + i))
        
        cat <<EOF >> $COMPOSE_FILE
  bsc-node-${i}:
    image: bsc-toolbox:latest
    container_name: bsc-node-${i}
    env_file: .env.cluster
    environment:
      - NODE_TYPE=node
      - NODE_INDEX=${i}
    volumes:
      - .:/node_deploy
    ports:
      - "${base_rpc}:8545" # RPC & WS
      - "${base_metrics}:6060" # Metrics
      - "${base_pprof}:7060" # Pprof
      - "${p2p_port}:${p2p_port}" # P2P TCP
      - "${p2p_port}:${p2p_port}/udp" # P2P UDP
    command: ["/node_deploy/node_entrypoint.sh"]

EOF
    done

    # Sentry
    if [ ${EnableSentryNode} = true ]; then
        for ((i=0; i<size; i++)); do
            base_rpc=$((8545 + i*2 + 100)) # Shift sentry ports
            base_metrics=$((6060 + i*2 + 100))
            base_pprof=$((7060 + i*2 + 100))
            p2p_port=$((30411 + i))
            
            cat <<EOF >> $COMPOSE_FILE
  bsc-sentry-${i}:
    image: bsc-toolbox:latest
    container_name: bsc-sentry-${i}
    env_file: .env.cluster
    environment:
      - NODE_TYPE=sentry
      - NODE_INDEX=${i}
    volumes:
      - .:/node_deploy
    ports:
      - "${base_rpc}:8545"
      - "${base_metrics}:6060"
      - "${base_pprof}:7060"
      - "${p2p_port}:${p2p_port}"
      - "${p2p_port}:${p2p_port}/udp"
    command: ["/node_deploy/node_entrypoint.sh"]

EOF
        done
    fi

    # Full Node
    if [ ${EnableFullNode} = true ]; then
        base_rpc=8645
        base_metrics=6160
        base_pprof=7160
        p2p_port=30511
        cat <<EOF >> $COMPOSE_FILE
  bsc-fullnode-0:
    image: bsc-toolbox:latest
    container_name: bsc-fullnode-0
    env_file: .env.cluster
    environment:
      - NODE_TYPE=full
      - NODE_INDEX=0
    volumes:
      - .:/node_deploy
    ports:
      - "${base_rpc}:8545"
      - "${base_metrics}:6060"
      - "${base_pprof}:7060"
      - "${p2p_port}:${p2p_port}"
      - "${p2p_port}:${p2p_port}/udp"
    command: ["/node_deploy/node_entrypoint.sh"]

EOF
    fi

    cat <<EOF >> $COMPOSE_FILE

networks:
  default:
    name: bsc_cluster_network
EOF

    echo "Generated \${COMPOSE_FILE} successfully!"
}

# 8. Use create-validator tool to register validator nodes on StakeHub
function register_stakehub(){
    # wait feynman enable
    for ((i = 0; i < size; i++));do
        create-validator --consensus-key-dir ${workspace}/keys/validator${i} --vote-key-dir ${workspace}/keys/bls${i} \
            --password-path ${workspace}/keys/password.txt --amount 20001 --validator-desc Val${i} --rpc-url ${RPC_URL}
    done
}

# Command dispatcher
CMD=$1
case ${CMD} in
prepare)
    echo "Preparing Docker cluster configs..."
    create_validator   # Step 1: Prepare keys and .local/
    prepare_bsc_client # Step 2: Build geth if necessary
    reset_genesis      # Step 3: Setup genesis deps (Forge, Poetry, etc)
    prepare_config     # Step 4: Generate genesis.json and node configs
    initNetwork        # Step 5: Initialize Geth data directories
    patch_p2p_network  # Step 6: Patch 127.0.0.1 in configs to docker DNS
    generate_compose   # Step 7: Generate .env.cluster and docker-compose
    echo "Preparation complete!"
    ;;
register)
    register_stakehub
    ;;
    wait-rpc)
        echo "Waiting for RPC to be available at http://localhost:8545..."
        MAX_WAIT=300 # 5 minutes
        ELAPSED=0
        until curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545 > /dev/null 2>&1; do
            printf "."
            sleep 2
            ELAPSED=$((ELAPSED + 2))
            if [ "$ELAPSED" -ge "$MAX_WAIT" ]; then
                echo ""
                echo "ERROR: RPC not available after ${MAX_WAIT}s. Aborting."
                exit 1
            fi
        done
        echo "RPC is ready!"
        ;;
*)
    echo "Usage: docker_cluster.sh | prepare | register"
    ;;
esac
