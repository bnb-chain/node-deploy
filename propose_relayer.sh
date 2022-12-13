#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
size=1
nodeurl="http://localhost:26657"
relayerAddr="0x9C0CE880F4DB90f16031929395707Da660b21Fdd"

function register_relayer() {
    ${workspace}/bin/bnbcli params submit-cscParam-change-proposal  \
     --side-chain-id ${BSC_CHAIN_NAME} \
     --key "addManager" \
     --from ${BBC_LOCAL_USER} \
     --chain-id "${BBC_CHAIN_ID}" \
     --node ${nodeurl} \
     --title "add new super trusty relayer" \
     --value ${relayerAddr} \
     --target "0x0000000000000000000000000000000000001006" \
     --deposit "200000000000:BNB" \
     --voting-period 100
}

function query_relayer() {
    ${workspace}/bin/bnbcli gov query-proposal  \
     --side-chain-id ${BSC_CHAIN_NAME} \
     --chain-id "${BBC_CHAIN_ID}" \
     --node ${nodeurl} \
     --proposal-id  1 
}

function vote_relayer() {
    ${workspace}/bin/bnbcli gov vote \
     --from ${BBC_LOCAL_USER} \
     --side-chain-id ${BSC_CHAIN_NAME} \
     --chain-id "${BBC_CHAIN_ID}" \
     --node ${nodeurl} \
     --proposal-id  1 \
     --option Yes
}

source ${workspace}/.env
CMD=$1

case ${CMD} in
vote)
    echo "===== clean ===="
    vote_relayer
    echo "===== end ===="
    ;;
propose)
    echo "===== clean ===="
    register_relayer
    echo "===== end ===="
    ;;
query)
    echo "===== clean ===="
    query_relayer
    echo "===== end ===="
    ;;
*)
    echo "Usage: propose_relayer.sh vote | propose | query"
    ;;
esac