#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env
source ${workspace}/utils.sh
size=$((${BSC_CLUSTER_SIZE}))
native_need_bls=false
nodeurl="http://localhost:26657"
replaceWhitelabelRelayer="0xb005741528b86F5952469d80A8614591E3c5B632"
initConsensusStateBytes=$(${workspace}/bin/tool -height 1 -rpc ${nodeurl} -network-type 1)
replaceConsensusStateBytes="42696e616e63652d436861696e2d4e696c650000000000000000000000000000000000000000000229eca254b3859bffefaf85f4c95da9fbd26527766b784272789c30ec56b380b6eb96442aaab207bc59978ba3dd477690f5c5872334fc39e627723daa97e441e88ba4515150ec3182bc82593df36f8abb25a619187fcfab7e552b94e64ed2deed000000e8d4a51000"

function exit_previous() {
	# stop client
    ps -ef  | grep geth | grep mine |awk '{print $2}' | xargs kill
}

# need a clean bc without stakings
function register_validator() {
    sleep 10 #wait for bc setup, otherwise may node-delegator not inclued in state
    rm -rf ${workspace}/.local/bsc

    for ((i=0;i<${size};i++));do
        mkdir -p ${workspace}/.local/bsc/validator${i}
        echo "${KEYPASS}" > ${workspace}/.local/bsc/password.txt
        
        cons_addr=$(${workspace}/bin/geth account new --datadir ${workspace}/.local/bsc/validator${i} --password ${workspace}/.local/bsc/password.txt | grep "Public address of the key:" | awk -F"   " '{print $2}')
        fee_addr=$(${workspace}/bin/geth account new --datadir ${workspace}/.local/bsc/validator${i}_fee --password ${workspace}/.local/bsc/password.txt | grep "Public address of the key:" | awk -F"   " '{print $2}')
        node_dir_index=${i}
        if [ $i -ge ${BBC_CLUSTER_SIZE} ]; then
            # echo "${KEYPASS}" | ${workspace}/bin/bnbcli keys delete node${i}-delegator --home ${workspace}/.local/bc/node0 # for re-entry
            echo "${KEYPASS}" | (echo "${KEYPASS}" | ${workspace}/bin/bnbcli keys add node${i}-delegator --home ${workspace}/.local/bc/node0)
            node_dir_index=0
        fi
        delegator=$(${workspace}/bin/bnbcli keys list --home ${workspace}/.local/bc/node${node_dir_index} | grep node${i}-delegator | awk -F" " '{print $3}')
        if [ "$i" != "0" ]; then
            sleep 6 #wait for including tx in block
            echo "${KEYPASS}" | ${workspace}/bin/bnbcli send --from node0-delegator --to $delegator --amount 5000000000000:BNB --chain-id ${BBC_CHAIN_ID} --node ${nodeurl} --home ${workspace}/.local/bc/node0
        fi
        sleep 6 #wait for including tx in block
        echo ${delegator} "balance"
        ${workspace}/bin/bnbcli account ${delegator}  --chain-id=Binance-Chain-Nile --home ${workspace}/.local/bc/node${node_dir_index} | jq .value.base.coins
        echo "${KEYPASS}" | ${workspace}/bin/bnbcli staking bsc-create-validator \
            --side-cons-addr "${cons_addr}" \
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
        echo "bin/geth do not exist!"
        exit 1
    fi
    rm -rf ${workspace}/.local/bsc/clusterNetwork
    mkdir ${workspace}/.local/bsc/clusterNetwork
    cd  ${workspace}/genesis
    git stash
    cd  ${workspace}
    git submodule update --remote
    cd  ${workspace}/genesis
    npm install
}

function prepare_config() {
    rm -f ${workspace}/genesis/validators.conf
    rm -f ${workspace}/genesis/init_holders.template
    cp ${workspace}/init_holders.template ${workspace}/genesis/init_holders.template

    sed -i -e "s/${replaceWhitelabelRelayer}/${INIT_HOLDER}/g" ${workspace}/genesis/contracts/System.template
    sed -i -e "s/false/true/g" ${workspace}/genesis/generate-relayerhub.js
    sed "s/{{INIT_HOLDER_ADDR}}/${INIT_HOLDER}/g" ${workspace}/genesis/init_holders.template > ${workspace}/genesis/init_holders.js
    sed -i -e "s/${replaceConsensusStateBytes}/${initConsensusStateBytes}/g" ${workspace}/genesis/generate-tendermintlightclient.js
    
    for ((i=0;i<${size};i++));do
        for f in ${workspace}/.local/bsc/validator${i}/keystore/*;do
            cons_addr="0x$(cat ${f} | jq -r .address)"
        done
        
        for f in ${workspace}/.local/bsc/validator${i}_fee/keystore/*;do
            fee_addr="0x$(cat ${f} | jq -r .address)"
        done
        
        mkdir -p ${workspace}/.local/bsc/clusterNetwork/node${i}
        
        bbcfee_addrs=`${workspace}/bin/bnbcli staking side-top-validators ${size} --side-chain-id=${BSC_CHAIN_NAME} --node="${nodeurl}" --chain-id=${BBC_CHAIN_ID} --trust-node --output=json| jq -r ".[${i}].distribution_addr" |xargs ${workspace}/bin/tool -addr`
        powers=`${workspace}/bin/bnbcli staking side-top-validators ${size} --side-chain-id=${BSC_CHAIN_NAME} --node="${nodeurl}" --chain-id=${BBC_CHAIN_ID} --trust-node --output=json| jq -r ".[${i}].tokens" |xargs ${workspace}/bin/tool -power`
        
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers}" >> ${workspace}/genesis/validators.conf
        echo "validator" ${i} ":" ${cons_addr}
        echo "validatorFee" ${i} ":" ${fee_addr}
    done

    cd ${workspace}/genesis/
    node generate-validator.js
    node generate-genesis.js --chainid ${BSC_CHAIN_ID} --bscChainId "$(printf '%04x\n' ${BSC_CHAIN_ID})"
}

function prepareBLSWallet(){
    echo "123456" > ${workspace}/.local/bsc/blspassword.txt
    for ((i=0;i<${size};i++));do
        sed -i.bak  '/BLSPasswordFile/d'  ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml #for re-entry
        sed -i.bak '/BLSWalletDir/d'  ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml  #for re-entry
        if [ "${native_need_bls}" = true ] ; then
            if [ ! -d "${workspace}/.local/bsc/clusterNetwork/node${i}/bls" ]; then
                expect create_bls_key.sh ${workspace}/.local/bsc/clusterNetwork/node${i}
            fi
            sed -i.bak 's/DataDir/BLSPasswordFile = \"{{BLSPasswordFile}}\"\nBLSWalletDir = \"{{BLSWalletDir}}\"\nDataDir/g'   ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml

            PassWordPath="${workspace}/.local/bsc/blspassword.txt"
            sed -i.bak "s:{{BLSPasswordFile}}:${PassWordPath}:g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
            WalletPath="${workspace}/.local/bsc/clusterNetwork/node${i}/bls/wallet"
            sed -i.bak "s:{{BLSWalletDir}}:${WalletPath}:g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        fi
    done
}

function generate() {
    cd ${workspace}
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc/clusterNetwork --init.size=${size} --config ${workspace}/config.toml ${workspace}/genesis/genesis.json
    for ((i=0;i<${size};i++));do
        staticPeers=$(generate_static_peers ${size} ${i})
        line=`grep -n -e 'StaticNodes' ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml | cut -d : -f 1`
        head -n $((line-1)) ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml >> ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e
        echo "StaticNodes = [${staticPeers}]" >> ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e
        tail -n +$(($line+1)) ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml >> ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e
        rm -f ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        mv ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml-e ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml

        sed -i -e "s/TriesInMemory = 0/TriesInMemory = 128/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
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
        sed -i -e "s/EulerBlock = 2/EulerBlock = 0\nNanoBlock = 0\nMoranBlock = 0\nGibbsBlock = 0\n/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
        
    done
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
         --from-file ${workspace}/.local/bsc/password.txt

        kubectl delete configmap config${i} -n bsc
        kubectl create configmap config${i} -n bsc \
         --from-file ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml

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

function native_start() {
    prepareBLSWallet

    for ((i=0;i<${size};i++));do
        cp -R ${workspace}/.local/bsc/validator${i}/keystore ${workspace}/.local/bsc/clusterNetwork/node${i}
        for j in ${workspace}/.local/bsc/validator${i}/keystore/*;do
            cons_addr="0x$(cat ${j} | jq -r .address)"
        done

        # sorry for magic
        for ((k=0;k<${size};k++));do
            p2p_port_k=$((30311 + k))
            if [ ${k} -ne ${i} ];then
                sed -i.bak "s/bsc-node-${k}.bsc.svc.cluster.local:30311/127.0.0.1:${p2p_port_k}/" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
            else
                sed -i.bak "s/\":30311/\":${p2p_port_k}/" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
            fi
        done
        HTTPPort=$((8545 + i))
        WSPort=${HTTPPort}

        nohup  ${workspace}/bin/geth --config ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml \
                            --datadir ${workspace}/.local/bsc/clusterNetwork/node${i} \
                            --password ${workspace}/.local/bsc/password.txt \
                            --nodekey ${workspace}/.local/bsc/clusterNetwork/node${i}/geth/nodekey \
                            -unlock ${cons_addr} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
                            --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
                            --metrics --metrics.addr 127.0.0.1 --metrics.expensive \
                            --gcmode archive --syncmode=full --mine \
                            > ${workspace}/.local/bsc/clusterNetwork/node${i}/bsc-node.log 2>&1 &
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
    echo "Usage: setup_bsc_node.sh register | generate | install_k8s | uninstall_k8s | native_start | native_stop"
    ;;
esac
