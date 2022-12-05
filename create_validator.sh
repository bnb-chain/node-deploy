#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
size=1
nodeurl="localhost:26657"
bscChainid=714
chain_id="local-testnet"

for ((i=0;i<${size};i++));do
    sideconsensus_addrs[$i]=`${workspace}/bin/bnbcli staking side-top-validators ${size}  --side-chain-id=bsc --node="${nodeurl}" --chain-id=${chain_id} --trust-node --output=json| jq .[${i}].side_cons_addr|cut -d"\"" -f2`
    sidefee_addrs[$i]=`${workspace}/bin/bnbcli staking side-top-validators ${size}  --side-chain-id=bsc --node="${nodeurl}" --chain-id=${chain_id} --trust-node --output=json| jq .[${i}].side_fee_addr|cut -d"\"" -f2`
    bbcfee_addrs[$i]=`${workspace}/bin/bnbcli staking side-top-validators ${size}  --side-chain-id=bsc --node="${nodeurl}" --chain-id=${chain_id} --trust-node --output=json| jq .[${i}].distribution_addr`
    powers[$i]=`${workspace}/bin/bnbcli staking side-top-validators ${size}  --side-chain-id=bsc --node="${nodeurl}" --chain-id=${chain_id} --trust-node --output=json| jq .[${i}].tokens`
done

mkdir -p ${workspace}/.local/bsc
rm -rf ${workspace}/.local/bsc/validators.conf
for ((i=0;i<${size};i++));do
     echo "${sideconsensus_addrs[$i]},${bbcfee_addrs[$i]},${sidefee_addrs[$i]},${powers[$i]}" >> ${workspace}/.local/bsc/validators.conf
done

