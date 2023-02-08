#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}

function prepare_docker_image() {
    rm -rf oracle-relayer
    git clone https://github.com/bnb-chain/oracle-relayer
    cd oracle-relayer
    make build_docker
}

function prepare_k8s_config() {
    mkdir -p ${workspace}/.local/relayer/
    rm -rf ${workspace}/.local/relayer/oracle_relayer.*
    cp oracle_relayer.template ${workspace}/.local/relayer/oracle_relayer.json

    sed -i -e "s/{{bsc_chain_id}}/${BSC_CHAIN_ID}/g" ${workspace}/.local/relayer/oracle_relayer.json
    mnemonic=$(cat ${workspace}/.local/bc/node0/node.info | jq .app_message.secret)
    sed -i -e "s/{{bbc_mnemonic}}/${mnemonic}/g" ${workspace}/.local/relayer/oracle_relayer.json

    kubectl create ns relayer
    kubectl delete configmap oracle-relayer -n relayer
    kubectl create configmap oracle-relayer -n relayer \
     --from-file ${workspace}/.local/relayer/oracle_relayer.json
}

function install_k8s() {
    helm install oracle-relayer \
    --namespace relayer --create-namespace \
    ${workspace}/helm/oracle-relayer
}

function uninstall_k8s() {
    helm uninstall oracle-relayer --namespace relayer
}

source ${workspace}/.env
CMD=$1

case ${CMD} in
docker)
    echo "===== init ===="
    prepare_docker_image
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
    echo "Usage: setup_bc_node.sh docker | install_k8s | uninstall_k8s"
    ;;
esac