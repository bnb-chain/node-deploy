#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
size=1
nodeurl="http://localhost:26657"
replaceWhitelabelRelayer="0xb005741528b86F5952469d80A8614591E3c5B632"
initConsensusStateBytes=$(${workspace}/bin/getInitConsensusState --height 1 --rpc ${nodeurl} --network-type testnet | awk -F"  " '{print $2}')
replaceConsensusStateBytes="42696e616e63652d436861696e2d4e696c650000000000000000000000000000000000000000000229eca254b3859bffefaf85f4c95da9fbd26527766b784272789c30ec56b380b6eb96442aaab207bc59978ba3dd477690f5c5872334fc39e627723daa97e441e88ba4515150ec3182bc82593df36f8abb25a619187fcfab7e552b94e64ed2deed000000e8d4a51000"

function register_validator() {
    rm -rf ${workspace}/.local/bsc
    mkdir -p ${workspace}/.local/bsc/validator/
    echo "${KEYPASS}" > ${workspace}/.local/bsc/password.txt
    cons_addr=$(${workspace}/bin/geth account new --datadir ${workspace}/.local/bsc/validator --password ${workspace}/.local/bsc/password.txt | grep "Public address of the key:" | awk -F"   " '{print $2}')
    fee_addr=$(${workspace}/bin/geth account new --datadir ${workspace}/.local/bsc/validator_fee --password ${workspace}/.local/bsc/password.txt | grep "Public address of the key:" | awk -F"   " '{print $2}')
    delegator=$(${workspace}/bin/bnbcli keys list | grep ${BBC_LOCAL_USER} | awk -F" " '{print $3}')

    ${workspace}/bin/bnbcli staking bsc-create-validator \
     --side-cons-addr "${cons_addr}" \
     --side-fee-addr "${fee_addr}" \
     --address-delegator "${delegator}" \
     --side-chain-id ${BSC_CHAIN_NAME} \
     --amount 10000000000000:BNB \
     --commission-rate 10000000 \
     --commission-max-rate 20000000 \
     --commission-max-change-rate 5000000 \
     --moniker "${cons_addr}" \
     --details "${cons_addr}" \
     --identity "${delegator}" \
     --website "http://localhost" \
     --from ${BBC_LOCAL_USER} \
     --chain-id "${BBC_CHAIN_ID}" \
     --node ${nodeurl}
}

function clean() {
    if ! [[ -f ${workspace}/bin/geth ]];then
        echo "bin/geth do not exist!"
        exit 1
    fi
    rm -rf ${workspace}/.local/bsc/clusterNetwork
    mkdir ${workspace}/.local/bsc/clusterNetwork
    cd  ${workspace}/genesis
    git stash
    cd  ${workspace}
    git submodule update
    cd  ${workspace}/genesis
    npm install
}

function prepare_config() {
    rm ${workspace}/genesis/validators.conf
    rm ${workspace}/genesis/init_holders.template
    cp ${workspace}/init_holders.template ${workspace}/genesis/init_holders.template

    for i in ${workspace}/.local/bsc/validator/keystore/*;do
     cons_addr="0x$(cat ${i} | jq -r .address)"
    done
    
    for i in ${workspace}/.local/bsc/validator_fee/keystore/*;do
     fee_addr="0x$(cat ${i} | jq -r .address)"
    done

    sed -i -e "s/${replaceWhitelabelRelayer}/${INIT_HOLDER}/g" ${workspace}/genesis/contracts/RelayerHub.template
    sed -i -e "s/false/true/g" ${workspace}/genesis/generate-relayerhub.js
    sed "s/{{INIT_HOLDER_ADDR}}/${INIT_HOLDER}/g" ${workspace}/genesis/init_holders.template > ${workspace}/genesis/init_holders.js
    sed -i -e "s/Binance-Chain-Nile/${BBC_CHAIN_ID}/g" ${workspace}/genesis/generate-tendermintlightclient.js
    sed -i -e "s/${replaceConsensusStateBytes}/${initConsensusStateBytes}/g" ${workspace}/genesis/generate-tendermintlightclient.js
    
    for ((i=0;i<${size};i++));do
        mkdir -p ${workspace}/clusterNetwork/node${i}

        echo "${cons_addr},${fee_addr},${fee_addr},0x0000000010000000" >> ${workspace}/genesis/validators.conf
        echo "validator" ${i} ":" ${cons_addr}
        echo "validatorFee" ${i} ":" ${fee_addr}
    done

    cd ${workspace}/genesis/
    node generate-validator.js
    node generate-genesis.js
    sed -i -e "s/\"chainId\": 714/\"chainId\": ${BSC_CHAIN_ID}/g" ${workspace}/genesis/genesis.json
}

function generate() {
    cd ${workspace}
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc/clusterNetwork --init.size=${size} --config ${workspace}/config.toml ${workspace}/genesis/genesis.json
    for ((i=0;i<${size};i++));do
        sed -i -e "s/NetworkId = 714/NetworkId = ${BSC_CHAIN_ID}/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/BerlinBlock/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/EWASMBlock/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/CatalystBlock/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/YoloV3Block/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/LondonBlock/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/ArrowGlacierBlock/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/MergeForkBlock/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/TerminalTotalDifficulty/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/BaseFee/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e '/RPCTxFeeCap/d' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e "s/MirrorSyncBlock = 1/MirrorSyncBlock = 0/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e "s/BrunoBlock = 1/BrunoBlock = 0/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        sed -i -e "s/EulerBlock = 2/EulerBlock = 0\nNanoBlock = 0\nMoranBlock = 0\n/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        
    done
}

function prepare_k8s_config() {
    kubectl create ns bsc
    kubectl delete secret keystore -n bsc
    files="" 
    for i in ${workspace}/.local/bsc/validator/keystore/*;do
     files="$files --from-file=$i"
    done
    bash -c "kubectl create secret generic keystore -n bsc ${files}"
    kubectl delete secret password -n bsc
    kubectl create secret generic password -n bsc \
     --from-file ${workspace}/.local/bsc/password.txt

    kubectl delete configmap configs -n bsc
    kubectl create configmap configs -n bsc \
     --from-file ${workspace}/.local/bsc/clusterNetwork/node0/config.toml
}

function install_k8s() {
    mkdir -p ${workspace}/.local/bsc
    rm -rf ${workspace}/.local/bsc/values.yaml
    cp ${workspace}/helm/bsc/values.yaml ${workspace}/.local/bsc/values.yaml
    for i in ${workspace}/.local/bsc/validator/keystore/*;do
     cons_addr="0x$(cat ${i} | jq -r .address)"
    done
    sed -i -e "s/0x00000000000000000000/${cons_addr}/g" ${workspace}/.local/bsc/values.yaml
    helm install bsc-node \
    --namespace bsc --create-namespace -f ${workspace}/.local/bsc/values.yaml \
    ${workspace}/helm/bsc
}

function uninstall_k8s() {
    helm uninstall bsc-node --namespace bsc
}

source ${workspace}/.env
CMD=$1

case ${CMD} in
register)
    echo "===== clean ===="
    register_validator
    echo "===== end ===="
    ;;
generate)
    echo "===== clean ===="
    clean
    echo "===== generate configs ===="
    prepare_config
    generate
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
*)
    echo "Usage: setup_bsc_node.sh register | generate | install_k8s | uninstall_k8s"
    ;;
esac