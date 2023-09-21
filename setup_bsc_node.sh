#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env
source ${workspace}/utils.sh
size=$((${BSC_CLUSTER_SIZE}))
initial_size=${BSC_CLUSTER_INITIAL_SIZE}
nodeurl="http://localhost:26657"
standalone=false 
authorities=("alice" "bob" "charlie" "dave" "eve") # predefined authorities
keys_dir_name="keys" # directory to store all the keys in

if [ ${size} -gt ${#authorities[@]} ]; then 
    echo "ERROR: BSC_CLUSTER_SIZE cannot be bigger than ${#authorities[@]}"
    exit 1
fi

if [ ${initial_size} -gt ${size} ]; then 
    echo "ERROR: BSC_CLUSTER_INITIAL_SIZE cannot be bigger than BSC_CLUSTER_SIZE"
    exit 1
fi



function exit_previous() {
	# stop client
    ps -ef  | grep geth | grep mine |awk '{print $2}' | xargs kill
}


# need a clean bc without stakings
function register_validator() {
    sleep 15 #wait for bc setup and all BEPs enabled, otherwise may node-delegator not inclued in state
    rm -rf ${workspace}/.local/bsc 
    mkdir -p ${workspace}/.local/bsc
    if [ -d "${workspace}/${keys_dir_name}" ]; then
        echo "${KEYPASS}" > ${workspace}/.local/password.txt
    else
        echo "${keys_dir_name} directory does not exist"
        exit 1
    fi

    for ((i=0;i<${size};i++));do
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
    
        if [ ${standalone} = true ]; then
            continue
        fi
        
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

function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf

    for ((i=0;i<${size};i++));do
        cd ${workspace}/${keys_dir_name}/${authorities[i]}
        cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
        fee_addr="0x$(cat fee/keystore/* | jq -r .address)"
        vote_addr=0x$(cat bls/keystore/*json| jq .pubkey | sed 's/"//g')
        cd ${workspace}
        bbcfee_addrs=${fee_addr}
        powers="0x000001d1a94a2000"
        if [ ${standalone} = false ]; then
            bbcfee_addrs=`${workspace}/bin/tbnbcli staking side-top-validators ${size} --side-chain-id=${BSC_CHAIN_NAME} --node="${nodeurl}" --chain-id=${BBC_CHAIN_ID} --trust-node --output=json| jq -r ".[${i}].distribution_addr" |xargs ${workspace}/bin/tool -network-type 0 -addr`
            powers=`${workspace}/bin/tbnbcli staking side-top-validators ${size} --side-chain-id=${BSC_CHAIN_NAME} --node="${nodeurl}" --chain-id=${BBC_CHAIN_ID} --trust-node --output=json| jq -r ".[${i}].tokens" |xargs ${workspace}/bin/tool -network-type 0 -power`
        fi
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/genesis/validators.conf
        echo "validator" ${i} ":" ${cons_addr}
        echo "validatorFee" ${i} ":" ${fee_addr}
        echo "validatorVote" ${i} ":" ${vote_addr}
    done

    cd ${workspace}/genesis/
    node generate-validator.js
    node generate-initHolders.js --initHolders ${INIT_HOLDER}
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
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc/clusterNetwork --init.size=${size} --config ${workspace}/config.toml ${workspace}/genesis/genesis.json
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

function native_start_single() {
    i="$1"
    cd ${workspace}/${keys_dir_name}/${authorities[i]}
    cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
    cd ${workspace}
    HTTPPort=$((8545 + i))
    WSPort=${HTTPPort}
    MetricsPort=$((6060 + i))

    cp -R ${workspace}/${keys_dir_name}/${authorities[i]}/bls ${workspace}/.local/bsc/clusterNetwork/node${i}
    cp -R ${workspace}/${keys_dir_name}/${authorities[i]}/consensus/keystore ${workspace}/.local/bsc/clusterNetwork/node${i}

    cp ${workspace}/bin/geth ${workspace}/.local/bsc/clusterNetwork/node${i}/geth${i}
    # init genesis
    ${workspace}/.local/bsc/clusterNetwork/node${i}/geth${i} init --datadir ${workspace}/.local/bsc/clusterNetwork/node${i} genesis/genesis.json
    # run BSC node
    nohup  ${workspace}/.local/bsc/clusterNetwork/node${i}/geth${i} --config ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml \
            --datadir ${workspace}/.local/bsc/clusterNetwork/node${i} \
            --password ${workspace}/.local/password.txt \
            --blspassword ${workspace}/.local/password.txt \
            --nodekey ${workspace}/.local/bsc/clusterNetwork/node${i}/geth/nodekey \
            -unlock ${cons_addr} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
            --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
            --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
            --gcmode archive --syncmode=full --mine --vote --monitor.maliciousvote \
            > ${workspace}/.local/bsc/clusterNetwork/node${i}/bsc-node.log 2>&1 &

}

function native_start() {
    for ((i=0;i<${initial_size};i++));do
       native_start_single "$i"
    done
}

CMD=$1
case ${CMD} in
register)
    echo "===== register ===="
    register_validator
    echo "===== end ===="
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
native_start_single)
    echo "===== start native single ===="
    native_start_single $2
    echo "===== start native single end ===="
    ;;
native_stop)
    echo "===== stop native ===="
    exit_previous
    sleep 5
    echo "===== stop native end ===="
    ;;
*)
    echo "Usage: setup_bsc_node.sh register | generate | generate_k8s | clean | install_k8s | uninstall_k8s | native_init | native_run_alone | native_start | native_start_single | native_stop"
    ;;
esac
