#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}

function prepare_docker_image() {
    rm -rf bsc-relayer
    git clone https://github.com/bnb-chain/bsc-relayer
    cd bsc-relayer
    go get -u golang.org/x/sys # fix compile issue
    sed -i -e "s/FROM golang:1.13-alpine/FROM golang:1.17-alpine/g" Dockerfile
    docker build . -t bsc-relayer
}

function prepare_k8s_config() {
    mnemonic=$(cat ${workspace}/.local/bc/info | jq .app_message.secret)

    mkdir -p ${workspace}/.local/relayer/
    rm -rf ${workspace}/.local/relayer/bsc_relayer.*
    cp bsc_relayer.template ${workspace}/.local/relayer/bsc_relayer.json
    sed -i -e "s/{{bsc_chain_id}}/${BSC_CHAIN_ID}/g" ${workspace}/.local/relayer/bsc_relayer.json
    sed -i -e "s/{{bbc_mnemonic}}/${mnemonic}/g" ${workspace}/.local/relayer/bsc_relayer.json
    sed -i -e "s/{{private_key}}/${INIT_HOLDER_PRV}/g" ${workspace}/.local/relayer/bsc_relayer.json

    kubectl create ns relayer
    kubectl delete configmap bsc-relayer -n relayer
    kubectl create configmap bsc-relayer -n relayer \
     --from-file ${workspace}/.local/relayer/bsc_relayer.json
}

function install_k8s() {
    helm install bsc-relayer \
    --namespace relayer --create-namespace \
    ${workspace}/helm/bsc-relayer
}

function uninstall_k8s() {
    helm uninstall bsc-relayer --namespace relayer
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