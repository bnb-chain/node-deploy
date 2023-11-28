#!/usr/bin/env bash

basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}


keys_dir_name="keys" # directory to store all the keys in

authorities=("alice" "bob" "charlie" "dave" "eve")
size=${#authorities[@]}

source ${workspace}/.env

function generate_keys() {
    rm -rf ${workspace}/${keys_dir_name}
    mkdir -p ${keys_dir_name}
    echo "${KEYPASS}" > ${workspace}/${keys_dir_name}/password.txt
    for ((i=0;i<${size};i++));do
        echo "Generating keys for ${authorities[i]} ... "
        mkdir -p ${workspace}/${keys_dir_name}/${authorities[i]}
        # create consensus address
        cons_addr=$(bin/geth account new --datadir ${workspace}/${keys_dir_name}/${authorities[i]}/consensus --password ${workspace}/${keys_dir_name}/password.txt)
        # create fee address
        fee_addr=$(bin/geth account new --datadir ${workspace}/${keys_dir_name}/${authorities[i]}/fee --password ${workspace}/${keys_dir_name}/password.txt)
        # create BLS key
        expect create_bls_key.exp ${workspace}/${keys_dir_name}/${authorities[i]} ${KEYPASS}
        # create node key
        openssl rand -hex 32 > ${workspace}/${keys_dir_name}/${authorities[i]}/nodekey
    done
}

function view_keys() {
    if [ -d "${workspace}/${keys_dir_name}" ]; then
        for ((i=0;i<${size};i++));do
            echo "${authorities[i]}'s addresses: "
            cd ${workspace}/${keys_dir_name}/${authorities[i]}
            cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
            echo "  Consensus Address: ${cons_addr}"
            fee_addr="0x$(cat fee/keystore/* | jq -r .address)"
            echo "  Fee Address: ${fee_addr}"
            vote_addr=0x$(cat bls/keystore/*json | jq .pubkey | sed 's/"//g')
            echo "  BLS Vote Address: ${vote_addr}"
            nodekey=$(cat nodekey)
            echo " Node key : ${nodekey}"
            enode=$(${workspace}/bin/bootnode -nodekeyhex ${nodekey} -writeaddress)
            echo "Enode: ${enode}"
            echo
        done
    else
        echo "${keys_dir_name} directory does not exist"
    fi
}


CMD=$1
case ${CMD} in
generate)
    echo "===== generate new keys ===="
    generate_keys
    echo "===== end ===="
    ;;
view)
    echo "===== view ===="
    view_keys
    ;;
*)
    echo "Usage: setup_keys.sh generate | view"
    ;;
esac
