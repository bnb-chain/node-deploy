#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env
source ${workspace}/utils.sh
size=$((${BBC_CLUSTER_SIZE}))

function exit_previous() {
	# stop client
    ps -ef  | grep bnbchaind | grep start |awk '{print $2}' | xargs kill
}

function init() {
    rm -rf ${workspace}/.local/bc/*
    mkdir -p ${workspace}/.local/bc/genTx
    node_ids=""

    for ((i=0;i<${size};i++));do
        mkdir -p ${workspace}/.local/bc/node${i}

        # make node info
        ${workspace}/bin/bnbchaind init --home ${workspace}/.local/bc/node${i} --chain-id ${BBC_CHAIN_ID} --moniker node${i} --kpass "${KEYPASS}" > ${workspace}/.local/bc/node${i}/node.info
        pod_domain="bc-node-${i}.bc.svc.cluster.local"
        node_ids="$(${workspace}/bin/bnbchaind tendermint show-node-id --home ${workspace}/.local/bc/node${i})@${pod_domain}:26656 ${node_ids}"

        # create delegator and operator account
        echo "${KEYPASS}" | ${workspace}/bin/bnbcli keys add node${i}-delegator --home ${workspace}/.local/bc/node${i} > ${workspace}/.local/bc/node${i}/delegator.info
        echo "${KEYPASS}" | ${workspace}/bin/bnbcli keys add node${i} --home ${workspace}/.local/bc/node${i} > ${workspace}/.local/bc/node${i}/operator.info

        # create validator
        nodeID=$(cat ${workspace}/.local/bc/node${i}/node.info | jq -r '.node_id')
        pubKey=$(cat ${workspace}/.local/bc/node${i}/node.info | jq -r '.pub_key')
        delegator=$(${workspace}/bin/bnbcli keys list --home ${workspace}/.local/bc/node${i} | grep node${i}-delegator | awk -F" " '{print $3}')
        ${workspace}/bin/bnbcli staking create-validator --chain-id=${BBC_CHAIN_ID} \
            --from node${i} --pubkey ${pubKey} --amount=1000000000:BNB \
            --moniker=node${i} --address-delegator=${delegator} --commission-rate=0 \
            --commission-max-rate=0 --commission-max-change-rate=0 --proposal-id=0 \
            --node-id=${nodeID} --genesis-format --home ${workspace}/.local/bc/node${i} \
            --generate-only > ${workspace}/.local/bc/node${i}/node${i}-unsigned.json 
        
        echo "${KEYPASS}" | ${workspace}/bin/bnbcli sign \
            ${workspace}/.local/bc/node${i}/node${i}-unsigned.json \
            --name "node${i}-delegator" --home ${workspace}/.local/bc/node${i} \
            --chain-id=${BBC_CHAIN_ID} --offline > ${workspace}/.local/bc/node${i}/node${i}-signed-t.json
        
        echo "${KEYPASS}" | ${workspace}/bin/bnbcli sign \
            ${workspace}/.local/bc/node${i}/node${i}-signed-t.json \
            --name "node${i}" --home ${workspace}/.local/bc/node${i} \
            --chain-id=${BBC_CHAIN_ID} --offline > ${workspace}/.local/bc/genTx/node${i}.json

        # modify configs
        sed -i -e "s/bscChainId = \"bsc\"/bscChainId = \"${BSC_CHAIN_NAME}\"/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/bscIbcChainId = 2/bscIbcChainId = ${BSC_CHAIN_ID}/g" ${workspace}/.local/bc/node${i}/config/app.toml

        sed -i -e "s/timeout_commit = \"1s\"/timeout_commit = \"${BBC_BLOCK_TIMEOUT}\"/g" ${workspace}/.local/bc/node${i}/config/config.toml
    
        sed -i -e "s/breatheBlockInterval = 0/breatheBlockInterval = ${BBC_BreatheBlockInterval}/g" ${workspace}/.local/bc/node${i}/config/app.toml

        
        sed -i -e "s/BEP6Height = 1/BEP6Height = 2/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP9Height = 1/BEP9Height = 2/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP10Height = 1/BEP10Height = 2/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP19Height = 1/BEP19Height = 2/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP12Height = 1/BEP12Height = 2/g" ${workspace}/.local/bc/node${i}/config/app.toml

        sed -i -e "s/BEP3Height = 1/BEP3Height = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/FixSignBytesOverflowHeight = 1/FixSignBytesOverflowHeight = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/LotSizeUpgradeHeight = 1/LotSizeUpgradeHeight = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/ListingRuleUpgradeHeight = 1/ListingRuleUpgradeHeight = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/FixZeroBalanceHeight = 1/FixZeroBalanceHeight = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/LaunchBscUpgradeHeight = 1/LaunchBscUpgradeHeight = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP8Height = 1/BEP8Height = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP67Height = 1/BEP67Height = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP70Height = 1/BEP70Height = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP67Height = 1/BEP67Height = 3/g" ${workspace}/.local/bc/node${i}/config/app.toml
        
        sed -i -e "s/BEP82Height = 9223372036854775807/BEP82Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP84Height = 9223372036854775807/BEP84Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP87Height = 9223372036854775807/BEP87Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/FixFailAckPackageHeight = 9223372036854775807/FixFailAckPackageHeight = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/EnableAccountScriptsForCrossChainTransferHeight = 9223372036854775807/EnableAccountScriptsForCrossChainTransferHeight = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP128Height = 9223372036854775807/BEP128Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP151Height = 9223372036854775807/BEP151Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP153Height = 9223372036854775807/BEP153Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/BEP173Height = 9223372036854775807/BEP173Height = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        sed -i -e "s/FixDoubleSignChainIdHeight = 9223372036854775807/FixDoubleSignChainIdHeight = 4/g" ${workspace}/.local/bc/node${i}/config/app.toml
        
    done

    # generate genesis.json
    ${workspace}/bin/bnbchaind collect-gentxs --chain-id ${BBC_CHAIN_ID} -i ${workspace}/.local/bc/genTx -o ${workspace}/.local/bc/genesis.json
    sed -i -e "s/\"min_self_delegation\": \"1000000000000\"/\"min_self_delegation\": \"100000000\"/g" ${workspace}/.local/bc/genesis.json
    
    # copy genesis file and set persistent peers
    persistent_peers=$(joinByString ',' ${node_ids})
    for ((i=0;i<${size};i++));do
        rm -rf ${workspace}/.local/bc/node${i}/config/genesis.json
        cp ${workspace}/.local/bc/genesis.json ${workspace}/.local/bc/node${i}/config/genesis.json

        sed -i -e "s/persistent_peers = \".*\"/persistent_peers = \"${persistent_peers}\"/g" ${workspace}/.local/bc/node${i}/config/config.toml
    done
}

function prepare_k8s_config() {
    kubectl create ns bc

    for ((i=0;i<${size};i++));do
        kubectl delete secret node${i} -n bc
        kubectl create secret generic node${i} -n bc \
         --from-file ${workspace}/.local/bc/node${i}/config/node_key.json \
         --from-file ${workspace}/.local/bc/node${i}/config/priv_validator_key.json

        kubectl delete configmap node${i}-configs -n bc
        kubectl create configmap node${i}-configs -n bc \
         --from-file ${workspace}/.local/bc/node${i}/config/app.toml \
         --from-file ${workspace}/.local/bc/node${i}/config/config.toml \
         --from-file ${workspace}/.local/bc/node${i}/config/genesis.json 
    done
}

function install_k8s() {
    for ((i=0;i<${size};i++));do
        helm install bc-node-${i} \
        --namespace bc --create-namespace \
        --set-string configName=node${i}-configs,secretName=node${i} \
        ${workspace}/./helm/bc
    done
}

function uninstall_k8s() {
    for ((i=0;i<${size};i++));do
        helm uninstall bc-node-${i} --namespace bc
    done
}


CMD=$1
case ${CMD} in
init)
    echo "===== init ===="
    init
    echo "===== end ===="
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
native_start) #only start node0!
    if [ ${BBC_CLUSTER_SIZE} -ne 1 ];then
        echo "native_start only support one node, please re-init with BBC_CLUSTER_SIZE=1"
        exit
    fi
    echo "===== stop native node0===="
    exit_previous
    sleep 5
    echo "===== stop native node0 end ===="

    echo "===== start native node0 ===="
    nohup ${workspace}/bin/bnbchaind start --home ${workspace}/.local/bc/node0 >> ${workspace}/.local/bc/node0/bc.log 2>&1 &
    echo "===== start native node0 end ===="
    ;;
native_stop)
    echo "===== stop native node0===="
    exit_previous
    sleep 5
    echo "===== stop native node0 end ===="
    ;;
*)
    echo "Usage: setup_bc_node.sh init | install_k8s | uninstall_k8s ｜ native_start | native_stop"
    ;;
esac