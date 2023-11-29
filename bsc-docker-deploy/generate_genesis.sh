#!/usr/bin/env bash

basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env
keys_dir_name="keys"
authorities=("alice" "bob" "charlie" "dave" "eve") # predefined authorities


# Get the number of validators to create from command line argument, default to number of authorities
num_validators=${1:-${#authorities[@]}}

function get_init_holders() {
    local result="${INIT_HOLDER}"
    # concatenate consensus addresses
    for ((i=0;i<${num_validators};i++));do
        cd ${workspace}/${keys_dir_name}/${authorities[i]}
        cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
        # If result already has data, append a comma before adding more
        if [[ -n $result ]]; then
            result+=","
        fi

        result+="$cons_addr"
        (( i++ ))
    done
    echo "$result"
}


# Check if the number of validators is greater than the number of authorities
if (( num_validators > ${#authorities[@]} )); then
    echo "Error: The number of validators requested (${num_validators}) is greater than the number of authorities available (${#authorities[@]})."
    exit 1
fi

rm -f ${workspace}/bsc-genesis-contract/validators.conf

for ((i=0;i<num_validators;i++));do
    cd ${workspace}/${keys_dir_name}/${authorities[i]}
    cons_addr="0x$(cat consensus/keystore/* | jq -r .address)"
    fee_addr="0x$(cat fee/keystore/* | jq -r .address)"
    vote_addr=0x$(cat bls/keystore/*json| jq .pubkey | sed 's/"//g')
    cd ${workspace}
    bbcfee_addrs=${fee_addr}
    powers="0x000001d1a94a2000"
    echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> ${workspace}/bsc-genesis-contract/validators.conf
    echo "validator" ${i} ":" ${cons_addr}
    echo "validatorFee" ${i} ":" ${fee_addr}
    echo "validatorVote" ${i} ":" ${vote_addr}
done

cd ${workspace}/bsc-genesis-contract/
node generate-validator.js
init_holders=$(get_init_holders)
echo "${init_holders}"
node generate-initHolders.js --initHolders ${init_holders}
node generate-genesis.js --chainid ${BSC_CHAIN_ID} --network 'local' --whitelist1Address ${INIT_HOLDER}