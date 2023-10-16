#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env
source ${workspace}/utils.sh
node_size=${BSC_NODE_SIZE}
validator_size=${BSC_VALIDATOR_SIZE}
nodeurl="http://localhost:26657"
standalone=false 
authorities=("alice" "bob" "charlie" "dave" "eve") # predefined authorities
keys_dir_name="keys" # directory to store all the keys in
validators_dir_name="validators" # directory to store all validator nodes

if [ ${validator_size} -gt ${#authorities[@]} ]; then 
    echo "ERROR: BSC_VALIDATOR_SIZE cannot be bigger than ${#authorities[@]}"
    exit 1
fi


function exit_previous() {
	# stop client
    ps -ef  | grep geth | grep bsc |awk '{print $2}' | xargs kill
}

function stop_validator() {
    authority_name="$1"
    echo "Stopping ${authority_name}"
    ps -ef | grep geth | grep bsc | grep "${authority_name}" | awk '{print $2}' | xargs kill
}

function stop_node() {
    i="$1"
    echo "Stopping node $i"
    ps -ef | grep geth | grep bsc | grep "node${i}" | awk '{print $2}' | xargs kill
}

function is_validator_running() {
    authority_name="$1"
    output=$(ps -ef | grep geth | grep bsc | grep "${authority_name}")
    if [[ -n $output ]]; then
        return 1
    else
        return 0
    fi
}

function is_node_running() {
    i="$1"
    output=$(ps -ef | grep geth | grep bsc | grep "node${i}")
    if [[ -n $output ]]; then
        return 1
    else
        return 0
    fi
}

function run_validator() {
    authority_name="$1"
    i=$(get_index "${authority_name}" "${authorities[@]}")
    if [ $i -lt 0 ]; then 
        echo "ERROR: validator with name ${authority_name} not found."
        exit 1
    fi
    validator_folder=${workspace}/.local/bsc/clusterNetwork/${validators_dir_name}/${authorities[i]}
    # check if validator is already setup
    if [ ! -d "${validator_folder}" ]; then
        echo "Validator ${authority_name} not yet set up. Setting up..."
        register_validator_single $i # register in beacon chain
        init_extra_validator $i # create and initialize the datadir
    else
        echo "Validator ${authority_name} already set up."
    fi

    # check if validator is already running
    is_validator_running ${authority_name}
    result=$?
    if [ $result -eq 1 ]; then 
        echo "Validator ${authority_name} is already up and running."
        exit 0
    else 
        echo "Running ${authority_name}..."
    fi

    if [ $i -lt ${validator_size} ]; then
        $(start_validator $i)
    else
        $(start_extra_validator $i)
    fi
}

function run_node() {
    i="$1"
    if [ $i -lt 0 ]; then 
        echo "ERROR: node index should be >- 0"
        exit 1
    fi
    node_folder=${workspace}/.local/bsc/clusterNetwork/node${i}
     # check if node is already setup
    if [ ! -d "${node_folder}" ]; then
        echo "Node $i not yet set up. Setting up..."
        init_extra_node $i # create and initialize the datadir
    else
        echo "Node $i already set up."
    fi

    # check if node is already running
    is_node_running $i
    result=$?
    if [ $result -eq 1 ]; then 
        echo "Node ${i} is already up and running."
        exit 0
    else 
        echo "Running node ${i}..."
    fi

    if [ $i -lt ${node_size} ]; then
        $(native_start_single_node $i)
    else
        $(start_extra_node $i)
    fi

}

function init_extra_node() {
    i="$1"
    node_folder=${workspace}/.local/bsc/clusterNetwork/node${i}
    mkdir -p ${node_folder}
    mkdir -p ${node_folder}/bin
    # copy geth binary
    cp ${workspace}/bin/geth ${node_folder}/bin/geth

    # copy genesis.json and config.toml
    cp ${workspace}/genesis/genesis.json ${node_folder}
    cp ${workspace}/config.toml ${node_folder}

    # init genesis
    ${node_folder}/bin/geth init --datadir ${node_folder} genesis/genesis.json
}


function init_extra_validator() {
    i="$1"
    validator_folder=${workspace}/.local/bsc/clusterNetwork/${validators_dir_name}/${authorities[i]}
    mkdir -p ${validator_folder}
    cp -R ${workspace}/${keys_dir_name}/${authorities[i]}/bls ${validator_folder}
    cp -R ${workspace}/${keys_dir_name}/${authorities[i]}/consensus/keystore ${validator_folder}
    # copy geth binary
    mkdir -p ${validator_folder}/bin
    cp ${workspace}/bin/geth ${validator_folder}/bin/geth

    # copy genesis.json and config.toml
    cp ${workspace}/genesis/genesis.json ${validator_folder}
    cp ${workspace}/config.toml ${validator_folder}

    # init genesis
    ${validator_folder}/bin/geth init --datadir ${validator_folder} genesis/genesis.json
}

function start_extra_node() {
    i="$1"
    HTTPPort=$((9545 + i))
    WSPort=${HTTPPort}
    MetricsPort=$((7060 + i))
    node_folder=${workspace}/.local/bsc/clusterNetwork/node${i}
    # run extra node
    # run normal BSC node
    nohup  ${node_folder}/bin/geth --config ${node_folder}/config.toml \
        --datadir ${node_folder} \
        --password ${workspace}/.local/password.txt \
        --nodekey ${node_folder}/geth/nodekey \
        --rpc.allow-unprotected-txs --allow-insecure-unlock  \
        --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
        --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
        --gcmode archive --syncmode=full  \
        --bootnodes "enode://03680e324b74bb9d6ebf37771d02eb9384c3869a1d0c90b595e5a40290345609171987df2ce36134c55613b5562cc5b373405558b9168670d2fa94cab3ca36d0@127.0.0.1:30312,enode://dcaa62f23fc9807a7b9ef479698a306c146738648e525bc7758a41353d150d04e3ba01aebcdcd14376a09a8179d5c1fb0ff83a17b6f6e738e71f5ff64b722656@127.0.0.1:30313" \
        --port $((40311+${node_size}+ ${validator_size} +$i)) \
        > ${node_folder}/bsc-node.log 2>&1 &
}

function start_extra_validator(){
    i="$1"
    HTTPPort=$((8545 + i))
    WSPort=${HTTPPort}
    MetricsPort=$((6060 + i))
    validator_folder=${workspace}/.local/bsc/clusterNetwork/${validators_dir_name}/${authorities[i]}
    cd ${validator_folder}
    cons_addr="0x$(cat keystore/* | jq -r .address)"
    cd ${workspace}
    # run extra BSC validator
    nohup  ${validator_folder}/bin/geth --config ${validator_folder}/config.toml \
        --datadir ${validator_folder} \
        --password ${workspace}/.local/password.txt \
        --blspassword ${workspace}/.local/password.txt \
        --nodekey ${validator_folder}/geth/nodekey \
        -unlock ${cons_addr} --miner.etherbase ${cons_addr} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
        --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
        --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
        --gcmode archive --syncmode=full --mine --vote --monitor.maliciousvote \
        --bootnodes "enode://d9da604d126271999f6724b3e698a852cc1fc77fca0ea5257b1bd9899a7c785624438908f7799bfea398659de9969da592241aa6a77972fe2fa61b5a812c43af@127.0.0.1:30312,enode://3bbefcb9b4a816c0977cc50f42ff066534adbc55fc91e7bcfbc2b4139a483b00251af242e3d46e2caff9f02a437ddba2b5e386a044ae228fea0299dd146063cd@127.0.0.1:30313" \
        --port $((50311+${node_size} +$i)) \
        > ${validator_folder}/bsc-node.log 2>&1 &

}

function register_validator_single() {
    i="$1"
    echo "${authorities[i]}'s addresses: "
    cd ${workspace}/${keys_dir_name}/${authorities[i]}
    cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
    echo "  Consensus Address: ${cons_addr}"
    fee_addr="0x$(cat fee/keystore/* | jq -r .address)"
    echo "  Fee Address: ${fee_addr}"
    vote_addr=0x$(cat bls/keystore/*json | jq .pubkey | sed 's/"//g')
    echo "  BLS Vote Address: ${vote_addr}"
    echo 

    cd ${workspace}
    
    node_dir_index=${i}
    if [ $i -ge ${BBC_CLUSTER_SIZE} ]; then
        # echo "${KEYPASS}" | ${workspace}/bin/tbnbcli keys delete node${i}-delegator --home ${workspace}/.local/bc/node0 # for re-entry
        echo "${KEYPASS}" | (echo "${KEYPASS}" | ${workspace}/bin/tbnbcli keys add node${i}-delegator --home ${workspace}/.local/bc/node0)
        node_dir_index=0
    fi
    delegator=$(${workspace}/bin/tbnbcli keys list --home ${workspace}/.local/bc/node${node_dir_index} | grep node${i}-delegator | awk -F" " '{print $3}')
    if [ "$i" != "0" ]; then
        sleep 6 #wait for including tx in block
        echo "${KEYPASS}" | ${workspace}/bin/tbnbcli send --from node0-delegator --to $delegator --amount 5000000000000:BNB --chain-id ${BBC_CHAIN_ID} --node ${nodeurl} --home ${workspace}/.local/bc/node0
    fi
    sleep 6 #wait for including tx in block
    echo ${delegator} "balance"
    ${workspace}/bin/tbnbcli account ${delegator}  --chain-id ${BBC_CHAIN_ID} --trust-node --home ${workspace}/.local/bc/node${node_dir_index} | jq .value.base.coins
    echo "${KEYPASS}" | ${workspace}/bin/tbnbcli staking bsc-create-validator \
        --side-cons-addr "${cons_addr}" \
        --side-vote-addr "${vote_addr}" \
        --bls-wallet ${workspace}/${keys_dir_name}/${authorities[i]}/bls/wallet \
        --bls-password "${KEYPASS}" \
        --side-fee-addr "${fee_addr}" \
        --address-delegator "${delegator}" \
        --side-chain-id ${BSC_CHAIN_NAME} \
        --amount 2000000000000:BNB \
        --commission-rate 80000000 \
        --commission-max-rate 95000000 \
        --commission-max-change-rate 3000000 \
        --moniker "${cons_addr}" \
        --details "${cons_addr}" \
        --identity "${delegator}" \
        --from node${i}-delegator \
        --chain-id "${BBC_CHAIN_ID}" \
        --node ${nodeurl} \
        --home ${workspace}/.local/bc/node${node_dir_index}

}

# need a clean bc without stakings
function register_validator() {
    rm -rf ${workspace}/.local/bsc 
    mkdir -p ${workspace}/.local/bsc

    if [ -d "${workspace}/${keys_dir_name}" ]; then
        echo "${KEYPASS}" > ${workspace}/.local/password.txt
    else
        echo "${keys_dir_name} directory does not exist"
        exit 1
    fi


    if [ ${standalone} = true ]; then
            return
    fi
    
    sleep 15 #wait for bc setup and all BEPs enabled, otherwise may node-delegator not included in state

    for ((i=0;i<${validator_size};i++));do
        register_validator_single $i
    done
}

function generate_static_peers() {
    tool=${workspace}/bin/bootnode
    num=$1
    target=$2
    staticPeers=""
    for ((i=0;i<$num;i++)); do
        if [ $i -eq $target ]
        then
           continue
        fi

        file=${workspace}/.local/bsc/clusterNetwork/node${i}/geth/nodekey
        if [ ! -f "$file" ]; then
            $tool -genkey $file
        fi
        port=30311
        domain="bsc-node-${i}.bsc.svc.cluster.local"
        if [ ! -z "$staticPeers" ]
        then
            staticPeers+=","
        fi
        staticPeers+='"'"enode://$($tool -nodekey $file -writeaddress)@$domain:$port"'"'
    done

    echo $staticPeers
}

function clean() {
    if ! [[ -f ${workspace}/bin/geth ]];then
        echo "bin/geth does not exist!"
        exit 1
    fi
    rm -rf ${workspace}/.local/bsc/clusterNetwork
    mkdir ${workspace}/.local/bsc/clusterNetwork
}

function get_init_holders() {
    local result="${INIT_HOLDER}"
    # concatenate consensus addresses
    for ((i=0;i<${validator_size};i++));do
        cd ${workspace}/${keys_dir_name}/${authorities[i]}
        cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
        # If result already has data, append a comma before adding more
        if [[ -n $result ]]; then
            result+=","
        fi

        result+="$cons_addr"
        (( i++ ))
    done
    echo "$result"
}


function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf

    for ((i=0;i<${validator_size};i++));do
        cd ${workspace}/${keys_dir_name}/${authorities[i]}
        cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
        fee_addr="0x$(cat fee/keystore/* | jq -r .address)"
        vote_addr=0x$(cat bls/keystore/*json| jq .pubkey | sed 's/"//g')
        cd ${workspace}
        bbcfee_addrs=${fee_addr}
        powers="0x000001d1a94a2000"
        if [ ${standalone} = false ]; then
            bbcfee_addrs=`${workspace}/bin/tbnbcli staking side-top-validators ${validator_size} --side-chain-id=${BSC_CHAIN_NAME} --node="${nodeurl}" --chain-id=${BBC_CHAIN_ID} --trust-node --output=json| jq -r ".[${i}].distribution_addr" |xargs ${workspace}/bin/tool -network-type 0 -addr`
            powers=`${workspace}/bin/tbnbcli staking side-top-validators ${validator_size} --side-chain-id=${BSC_CHAIN_NAME} --node="${nodeurl}" --chain-id=${BBC_CHAIN_ID} --trust-node --output=json| jq -r ".[${i}].tokens" |xargs ${workspace}/bin/tool -network-type 0 -power`
        fi
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/genesis/validators.conf
        echo "validator" ${i} ":" ${cons_addr}
        echo "validatorFee" ${i} ":" ${fee_addr}
        echo "validatorVote" ${i} ":" ${vote_addr}
    done

    cd ${workspace}/genesis/
    node generate-validator.js
    init_holders=$(get_init_holders)
    node generate-initHolders.js --initHolders ${init_holders}
    if [ ${standalone} = false ]; then
        initConsensusStateBytes=$(${workspace}/bin/tool -height 1 -rpc ${nodeurl} -network-type 0)
        node generate-genesis.js --chainid ${BSC_CHAIN_ID} --network 'local' --whitelist1Address ${INIT_HOLDER} --initConsensusStateBytes  ${initConsensusStateBytes}
    else
        node generate-genesis.js --chainid ${BSC_CHAIN_ID} --network 'local' --whitelist1Address ${INIT_HOLDER}
    fi

}

function initNetwork_k8s() {
   cd ${workspace}
   ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc/clusterNetwork --init.ips=${ips_string} --init.size=${size} --config ${workspace}/config.toml ${workspace}/genesis/genesis.json
    for ((i=0;i<${size};i++));do
        staticPeers=$(generate_static_peers ${size} ${i})
        line=`grep -n -e 'StaticNodes' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml | cut -d : -f 1`
        head -n $((line-1)) ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml >> ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e
        echo "StaticNodes = [${staticPeers}]" >> ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e
        tail -n +$(($line+1)) ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml >> ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e
        rm -f ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        mv ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
    done
   rm -rf  ${workspace}/*bsc.log*
}

function initNetwork() {
    cd ${workspace}
    mkdir -p ${workspace}/.local/bsc/clusterNetwork/${validators_dir_name} # root directory for validators
    size=$((${validator_size} + ${node_size}))
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc/clusterNetwork --init.size=${size} --config ${workspace}/config.toml ${workspace}/genesis/genesis.json
    # initialize validators
    # rename validator folders to alice, bob ... and  copy keys to validators' folders
    for ((i=0;i<${validator_size};i++));do
        validator_folder=${workspace}/.local/bsc/clusterNetwork/${validators_dir_name}/${authorities[i]}
        mv  ${workspace}/.local/bsc/clusterNetwork/node${i}  ${validator_folder}
        cp -R ${workspace}/${keys_dir_name}/${authorities[i]}/bls ${validator_folder}
        cp -R ${workspace}/${keys_dir_name}/${authorities[i]}/consensus/keystore ${validator_folder}
        # copy geth binary
        mkdir -p ${validator_folder}/bin
        cp ${workspace}/bin/geth ${validator_folder}/bin/geth
        # init genesis
        ${validator_folder}/bin/geth init --datadir ${validator_folder} genesis/genesis.json
    done

    # initialize normal nodes
    for ((i=0;i<${node_size};i++));do
        # normal nodes need to be renamed to start from node0
        node_folder=${workspace}/.local/bsc/clusterNetwork/node${i}
        mv ${workspace}/.local/bsc/clusterNetwork/node$((${validator_size}+$i)) ${node_folder}
        # copy geth binary
        mkdir -p ${node_folder}/bin
        cp ${workspace}/bin/geth ${node_folder}/bin/geth
        # init genesis
        ${node_folder}/bin/geth init --datadir ${node_folder} genesis/genesis.json
    done
    rm -rf  ${workspace}/*bsc.log*
}

function prepare_k8s_config() {
    kubectl create ns bsc

    for ((i=0;i<${size};i++));do
        kubectl delete secret keystore${i} -n bsc
        files="" 
        for f in ${workspace}/.local/bsc/validator${i}/keystore/*;do
         files="$files --from-file=$f"
        done
        bash -c "kubectl create secret generic keystore${i} -n bsc ${files}"

        kubectl delete secret password -n bsc
        kubectl create secret generic password -n bsc \
         --from-file ${workspace}/.local/password.txt

        kubectl delete configmap config${i} -n bsc
        kubectl create configmap config${i} -n bsc \
         --from-file ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml \
         --from-file ${workspace}/genesis/genesis.json 

        kubectl delete configmap nodekey${i} -n bsc
        kubectl create configmap nodekey${i} -n bsc \
         --from-file ${workspace}/.local/bsc/clusterNetwork/node${i}/geth/nodekey
    done
    
}

function install_k8s() {
    for ((i=0;i<${size};i++));do
        helm install bsc-node-${i} \
         --namespace bsc --create-namespace \
         --set-string configName=config${i},secretName=keystore${i},nodeKeyCfgName=nodekey${i} \
         ${workspace}/helm/bsc 
    done
}

function uninstall_k8s() {
    for ((i=0;i<${size};i++));do
        helm uninstall bsc-node-${i} --namespace bsc
    done
}

function start_validator() {
    i="$1"
    HTTPPort=$((8545 + i))
    WSPort=${HTTPPort}
    MetricsPort=$((6060 + i))
    validator_folder=${workspace}/.local/bsc/clusterNetwork/${validators_dir_name}/${authorities[i]}
    cd ${validator_folder}
    cons_addr="0x$(cat keystore/* | jq -r .address)"
    cd ${workspace}
    # run BSC validator
    nohup  ${validator_folder}/bin/geth --config ${validator_folder}/config.toml \
        --datadir ${validator_folder} \
        --password ${workspace}/.local/password.txt \
        --blspassword ${workspace}/.local/password.txt \
        --nodekey ${validator_folder}/geth/nodekey \
        -unlock ${cons_addr}  --miner.etherbase ${cons_addr} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
        --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
        --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
        --gcmode archive --syncmode=full --mine --vote --monitor.maliciousvote \
        > ${validator_folder}/bsc-node.log 2>&1 &
}

function native_start_single_validator() {
    authority_name="$1"
    i=$(get_index "${authority_name}" "${authorities[@]}")
    if [ $i -lt 0 ]; then 
        echo "ERROR: validator with name ${authority_name} not found."
        exit 1
    else
       $(start_validator $i)
    fi
}

function native_start_single_node() {
    i="$1"
    HTTPPort=$((9545 + i))
    WSPort=${HTTPPort}
    MetricsPort=$((7060 + i))
    node_folder=${workspace}/.local/bsc/clusterNetwork/node${i}
   
    # run normal BSC node
    nohup  ${node_folder}/bin/geth --config ${node_folder}/config.toml \
        --datadir ${node_folder} \
        --password ${workspace}/.local/password.txt \
        --nodekey ${node_folder}/geth/nodekey \
        --rpc.allow-unprotected-txs --allow-insecure-unlock  \
        --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
        --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
        --gcmode archive --syncmode=full  \
        > ${node_folder}/bsc-node.log 2>&1 &
}

function native_start() {
    # start validators
    echo "Starting validators..."
    for ((i=0;i<${validator_size};i++));do
        start_validator $i
    done

    # start normal nodes
    echo "Starting full nodes..."
    for ((i=0;i<${node_size};i++));do
        native_start_single_node $i
    done
}

CMD=$1
case ${CMD} in
register)
    echo "===== register ===="
    register_validator
    echo "===== end ===="
    ;;
run_validator)
    echo "===== run validator ===="
    run_validator $2
    echo "===== end ===="
    ;;
stop_validator)
    echo "===== stop validator ===="
    stop_validator $2
    echo "===== end ===="
    ;;
run_node)
    echo "===== run node ====="
    run_node $2
    echo "===== end ======"
    ;;
stop_node)
    echo "===== stop node ====="
    stop_node $2
    echo "===== end ======"
    ;;
generate)
    echo "===== clean ===="
    clean
    echo "===== generate configs ===="
    prepare_config
    initNetwork
    echo "===== end ===="
    ;;
generate_k8s)
    echo "===== clean ===="
    clean
    echo "===== generate configs for k8s ===="
    prepare_config
    initNetwork_k8s
    echo "===== end ===="
    ;;    
clean)
    echo "===== clean ===="
    clean
    ;;
install_k8s)
    echo "===== k8s install ===="
    prepare_k8s_config
    install_k8s
    echo "===== end ===="
    ;;
uninstall_k8s)
    echo "===== k8s uninstall ===="
    uninstall_k8s
    echo "===== end ===="
    ;;
native_init)
    echo "===== register ===="
    register_validator
    echo "===== end ===="
    echo "===== clean ===="
    clean
    echo "===== generate configs ===="
    prepare_config
    initNetwork
    echo "===== end ===="
    ;;
native_run_alone)
    standalone=true
    echo "===== register ===="
    register_validator
    echo "===== end ===="
    echo "===== clean ===="
    clean
    echo "===== generate configs ===="
    prepare_config
    initNetwork
    echo "===== end ===="
    echo "===== start native ===="
    native_start
    echo "===== start native end ===="
    ;;
native_start) # can re-entry
    echo "===== stop native ===="
    exit_previous
    sleep 10
    echo "===== stop native end ===="

    echo "===== start native ===="
    native_start
    echo "===== start native end ===="
    ;;
native_stop)
    echo "===== stop native ===="
    exit_previous
    sleep 5
    echo "===== stop native end ===="
    ;;
*)
    echo "Usage: setup_bsc_node.sh register | generate | generate_k8s | clean | install_k8s | uninstall_k8s | native_init | native_run_alone | native_start  | run_validator <validator_name> | stop_validator <validator_name> | run_node <node_index> | stop_node <node_index> | native_stop"
    ;;
esac
