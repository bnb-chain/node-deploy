#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}

function exit_previous() {
	# stop client
    ps -ef  | grep oracle-relayer | grep config |awk '{print $2}' | xargs kill
}

function build_relayer() {
    rm -rf oracle-relayer
    git clone https://github.com/bnb-chain/oracle-relayer
    cd oracle-relayer
    make build
    cd build && mv relayer oracle-relayer
}

function prepare_docker_image() {
    rm -rf oracle-relayer
    git clone https://github.com/bnb-chain/oracle-relayer
    cd oracle-relayer
    make build_docker
}

function init_config(){
    mkdir -p ${workspace}/.local/relayer/
    rm -rf ${workspace}/.local/relayer/oracle_relayer.*
    cp ${workspace}/oracle_relayer.template ${workspace}/.local/relayer/oracle_relayer.json

    sed -i -e "s/{{bsc_chain_id}}/${BSC_CHAIN_ID}/g" ${workspace}/.local/relayer/oracle_relayer.json
    mnemonic="\"$(cat ${workspace}/.local/bc/node0/operator.info |tail  -1)\""
    sed -i -e "s/{{bbc_mnemonic}}/${mnemonic}/g" ${workspace}/.local/relayer/oracle_relayer.json
}

function prepare_k8s_config() {
    init_config
    kubectl create ns relayer
    kubectl delete configmap oracle-relayer -n relayer
    kubectl create configmap oracle-relayer -n relayer \
     --from-file ${workspace}/.local/relayer/oracle_relayer.json
}

function prepare_native_config() {
    init_config
    LAN_IP=$(ifconfig |grep 192.168 |awk -F" " '{print $2}' |head -1)
    sed -i -e "s/bc-node-0.bc.svc.cluster.local/${LAN_IP}/g" ${workspace}/.local/relayer/oracle_relayer.json
    sed -i -e "s/bsc-node-0.bsc.svc.cluster.local/${LAN_IP}/g" ${workspace}/.local/relayer/oracle_relayer.json 
    sed -i -e "s:/data/relayer.db:${workspace}/.local/relayer/oracle_relayer.db:g" ${workspace}/.local/relayer/oracle_relayer.json 
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
native_init)
    echo "===== init ===="
    build_relayer
    prepare_native_config
    echo "===== end ===="
    ;;
native_start)
    echo "===== stop native oracle-relayer===="
    exit_previous
    sleep 5
    echo "===== stop native oracle-relayer end ===="

    echo "===== start native node0 ===="
    cp ${workspace}/oracle-relayer/build/oracle-relayer ${workspace}/.local/relayer/
    nohup ${workspace}/.local/relayer/oracle-relayer --bbc-network 0 --config-type local --config-path ${workspace}/.local/relayer/oracle_relayer.json > ${workspace}/.local/relayer/oracle_relayer.log 2>&1 &
    echo "===== start native node0 end ===="
    ;;
native_stop)
    echo "===== stop native node0 ===="
    exit_previous
    sleep 5
    echo "===== stop native node0 end ===="
    ;;
*)
    echo "Usage: setup_bc_node.sh docker | install_k8s | uninstall_k8s | native_init | native_start | native_stop"
    ;;
esac
