#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
initHolder="0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186"
replaceWhitelabelRelayer="0xb005741528b86F5952469d80A8614591E3c5B632"
initConsensusStateBytes=$(${workspace}/bin/getInitConsensusState --height 1 --rpc localhost:26657 --network-type testnet | awk -F"  " '{print $2}')
replaceConsensusStateBytes="42696e616e63652d436861696e2d4e696c650000000000000000000000000000000000000000000229eca254b3859bffefaf85f4c95da9fbd26527766b784272789c30ec56b380b6eb96442aaab207bc59978ba3dd477690f5c5872334fc39e627723daa97e441e88ba4515150ec3182bc82593df36f8abb25a619187fcfab7e552b94e64ed2deed000000e8d4a51000"
size=1
bscChainid=714
chain_id="local-testnet"


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


function prepareValidatorAccount() {
    rm ${workspace}/genesis/validators.conf
    rm ${workspace}/genesis/init_holders.template
    cp ${workspace}/init_holders.template ${workspace}/genesis/init_holders.template
    sed -i -e "s/${replaceWhitelabelRelayer}/${initHolder}/g" ${workspace}/genesis/contracts/System.template
    sed -i -e "s/false/true/g" ${workspace}/genesis/generate-relayerhub.js
    sed "s/{{INIT_HOLDER_ADDR}}/${initHolder}/g" ${workspace}/genesis/init_holders.template > ${workspace}/genesis/init_holders.js
    sed -i -e "s/Binance-Chain-Nile/${chain_id}/g"  ${workspace}/genesis/generate-tendermintlightclient.js
    sed -i -e "s/${replaceConsensusStateBytes}/${initConsensusStateBytes}/g"  ${workspace}/genesis/generate-tendermintlightclient.js
    
    for ((i=0;i<${size};i++));do
        mkdir -p ${workspace}/clusterNetwork/node${i}

        validatorAddr="0x56cF6C1EF1315b2fE7b549c87BBe7851F14F0C44"
        validatorFeeAddr="0x43e44a05ecf8316e254b4aa1ca1c82c5ccd213b9"
        #  password=`openssl rand -base64 10`
        #  echo "${password}" > ${workspace}/clusterNetwork/node${i}/password.txt
        #  ${workspace}/bin/geth --datadir ${workspace}/clusterNetwork/node${i} account new --password ${workspace}/clusterNetwork/node${i}/password.txt > ${workspace}/clusterNetwork/validator${i}Info
        #  validatorAddr=`cat ${workspace}/clusterNetwork/validator${i}Info|grep 'Public address of the key'|awk '{print $6}'`
        #  ${workspace}/bin/geth --datadir ${workspace}/clusterNetwork/node${i} account new --password ${workspace}/clusterNetwork/node${i}/password.txt > ${workspace}/clusterNetwork/validatorFee${i}Info
        #  validatorFeeAddr=`cat ${workspace}/clusterNetwork/validatorFee${i}Info|grep 'Public address of the key'|awk '{print $6}'`

        echo "${validatorAddr},${validatorFeeAddr},${validatorFeeAddr},0x0000000010000000" >> ${workspace}/genesis/validators.conf
        echo "validator" ${i} ":" ${validatorAddr}
        echo "validatorFee" ${i} ":" ${validatorFeeAddr}
    done

    cd ${workspace}/genesis/
    node generate-validator.js
    node generate-genesis.js
    sed -i -e "s/\"chainId\": 714/\"chainId\": ${bscChainid}/g"  ${workspace}/genesis/genesis.json
}

function generate() {
    cd ${workspace}
    ${workspace}/bin/geth init-network --init.dir ${workspace}/.local/bsc/clusterNetwork --init.size=${size} --config ${workspace}/config.toml ${workspace}/genesis/genesis.json
    for ((i=0;i<${size};i++));do
        sed -i -e "s/NetworkId = 714/NetworkId = ${bscChainid}/g" ${workspace}/.local/bsc/clusterNetwork/node${i}/config.toml
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
    done
}


clean
prepareValidatorAccount
generate
