#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}

function init() {
    mkdir -p ${workspace}/.local/bc
    rm -rf ${workspace}/.local/bc/*
    ${workspace}/bin/bnbchaind init --home ./.local/bc --chain-id ${BBC_CHAIN_ID} --moniker ${BBC_LOCAL_USER} --kpass "${KEYPASS}" > ${workspace}/.local/bc/info

    sed -i -e "s/bscChainId = \"bsc\"/bscChainId = \"${BSC_CHAIN_NAME}\"/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/bscIbcChainId = 2/bscIbcChainId = ${BSC_CHAIN_ID}/g" ${workspace}/.local/bc/config/app.toml

    sed -i -e "s/timeout_commit = \"1s\"/timeout_commit = \"${BBC_BLOCK_TIMEOUT}\"/g" ${workspace}/.local/bc/config/config.toml
    
    sed -i -e "s/breatheBlockInterval = 0/breatheBlockInterval = ${BBC_BreatheBlockInterval}/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/BEP82Height = 9223372036854775807/BEP82Height = 1/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/BEP84Height = 9223372036854775807/BEP84Height = 1/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/BEP87Height = 9223372036854775807/BEP87Height = 1/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/FixFailAckPackageHeight = 9223372036854775807/FixFailAckPackageHeight = 1/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/EnableAccountScriptsForCrossChainTransferHeight = 9223372036854775807/EnableAccountScriptsForCrossChainTransferHeight = 1/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/BEP128Height = 9223372036854775807/BEP128Height = 1/g" ${workspace}/.local/bc/config/app.toml
    sed -i -e "s/BEP151Height = 9223372036854775807/BEP151Height = 1/g" ${workspace}/.local/bc/config/app.toml
}

function prepare_k8s_config() {
    kubectl create ns bc
    kubectl delete secret keyfile -n bc
    kubectl create secret generic keyfile -n bc \
     --from-file ${workspace}/.local/bc/config/node_key.json \
     --from-file ${workspace}/.local/bc/config/priv_validator_key.json

    kubectl delete configmap configs -n bc
    kubectl create configmap configs -n bc \
     --from-file ${workspace}/.local/bc/config/app.toml \
     --from-file ${workspace}/.local/bc/config/config.toml \
     --from-file ${workspace}/.local/bc/config/genesis.json 
}

function install_k8s() {
    helm install bc-node \
    --namespace bc --create-namespace \
    ${workspace}/./helm/bc
}

function uninstall_k8s() {
    helm uninstall bc-node --namespace bc
}

source ${workspace}/.env
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
*)
    echo "Usage: setup_bc_node.sh init | install_k8s | uninstall_k8s"
    ;;
esac