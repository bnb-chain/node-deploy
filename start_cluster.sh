#!/usr/bin/env bash
basedir=$(
    cd $(dirname $0)
    pwd
)
workspace=${basedir}
source "${workspace}"/.env
size=$((BSC_CLUSTER_SIZE))
stateScheme="hash"

# stop geth client
function exit_previous() {
    ps -ef  | grep geth | grep mine |awk '{print $2}' | xargs kill
    sleep 5
}

function create_validator() {
    rm -rf "${workspace}"/.local/bsc

    for ((i = 0; i < size; i++)); do
        mkdir -p "${workspace}"/.local/bsc/validator${i}
        echo "${KEYPASS}" > "${workspace}"/.local/bsc/password.txt

        cons_addr=$("${workspace}"/bin/geth account new --datadir "${workspace}"/.local/bsc/validator${i} --password "${workspace}"/.local/bsc/password.txt | grep "Public address of the key:" | awk -F"   " '{print $2}')
        fee_addr=$("${workspace}"/bin/geth account new --datadir "${workspace}"/.local/bsc/validator${i}_fee --password "${workspace}"/.local/bsc/password.txt | grep "Public address of the key:" | awk -F"   " '{print $2}')
        mkdir -p "${workspace}"/.local/bsc/bls${i}
        "${workspace}"/bin/geth bls account new --datadir "${workspace}"/.local/bsc/bls${i} --blspassword "${workspace}"/.local/bsc/password.txt
        vote_addr=0x$(cat "${workspace}"/.local/bsc/bls${i}/bls/keystore/*json | jq .pubkey | sed 's/"//g')
    done
}

function generate_static_peers() {
    tool="${workspace}"/bin/bootnode
    num=$1
    target=$2
    staticPeers=""
    for ((i = 0; i < num; i++)); do
        if [ $i -eq $target ]; then
            continue
        fi

        file="${workspace}"/.local/bsc/node${i}/geth/nodekey
        if [ ! -f "$file" ]; then
            $tool -genkey $file
        fi
        port=30311
        domain="bsc-node-${i}.bsc.svc.cluster.local"
        if [ -n "$staticPeers" ]; then
            staticPeers+=","
        fi
        staticPeers+='"'"enode://$($tool -nodekey $file -writeaddress)@$domain:$port"'"'
    done

    echo $staticPeers
}

# reset genesis, but keep edited genesis-template.json
function reset_genesis() {
    cd  ${workspace}/genesis
    cp ./genesis-template.json ../
    git stash
    cd  ${workspace}
    git submodule update --remote
    mv ./genesis-template.json ./genesis/
    cd  ${workspace}/genesis
    npm install
}

function prepare_config() {
    rm -f "${workspace}"/genesis/validators.conf

    for ((i = 0; i < ${size}; i++)); do
        for f in "${workspace}"/.local/bsc/validator${i}/keystore/*; do
            cons_addr="0x$(cat ${f} | jq -r .address)"
        done

        for f in "${workspace}"/.local/bsc/validator${i}_fee/keystore/*; do
            fee_addr="0x$(cat ${f} | jq -r .address)"
        done

        mkdir -p "${workspace}"/.local/bsc/node${i}
        bbcfee_addrs=${fee_addr}
        powers="0x000001d1a94a2000"
        mv "${workspace}"/.local/bsc/bls${i}/bls "${workspace}"/.local/bsc/node${i}/ && rm -rf "${workspace}"/.local/bsc/bls${i}
        vote_addr=0x$(cat "${workspace}"/.local/bsc/node${i}/bls/keystore/*json | jq .pubkey | sed 's/"//g')
        echo "${cons_addr},${bbcfee_addrs},${fee_addr},${powers},${vote_addr}" >> "${workspace}"/genesis/validators.conf
        echo "validator" ${i} ":" ${cons_addr}
        echo "validatorFee" ${i} ":" ${fee_addr}
        echo "validatorVote" ${i} ":" ${vote_addr}
    done

    cd "${workspace}"/genesis/
    git checkout HEAD contracts

    if [ ! -d "${workspace}/genesis/lib/forge-std" ];then
        forge install --no-git --no-commit foundry-rs/forge-std@v1.7.3
    fi

    hardforkTime=$(expr $(date +%s) + ${HARD_FORK_DELAY})
    echo "hardforkTime "${hardforkTime} > "${workspace}"/.local/bsc/hardforkTime.txt
    sed -i -e '/shanghaiTime/d' ./genesis-template.json
    sed -i -e '/keplerTime/d' ./genesis-template.json
    sed -i -e '/feynmanTime/d' ./genesis-template.json

    python3 scripts/generate.py generate-validators
    python3 scripts/generate.py generate-init-holders "${INIT_HOLDER}"
    python3 scripts/generate.py dev --dev-chain-id "${BSC_CHAIN_ID}" --whitelist-1 "${INIT_HOLDER}" \
      --epoch "20" --misdemeanor-threshold "5" --felony-threshold "10" \
      --init-felony-slash-scope "60" \
      --breathe-block-interval "1 minutes" \
      --block-interval "1" \
      --init-bc-consensus-addresses 'hex"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb9226600000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c80000000000000000000000003c44cdddb6a900fa2b585dd299e03d12fa4293bc"' \
      --init-bc-vote-addresses 'hex"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000030b86b3146bdd2200b1dbdb1cea5e40d3451c028cbb4fb03b1826f7f2d82bee76bbd5cd68a74a16a7eceea093fd5826b9200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003087ce273bb9b51fd69e50de7a8d9a99cfb3b1a5c6a7b85f6673d137a5a2ce7df3d6ee4e6d579a142d58b0606c4a7a1c27000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030a33ac14980d85c0d154c5909ebf7a11d455f54beb4d5d0dc1d8b3670b9c4a6b6c450ee3d623ecc48026f09ed1f0b5c1200000000000000000000000000000000"' \
      --stake-hub-protector "0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186" \
      --unbond-period "2 minutes" \
      --downtime-jail-time "2 minutes" \
      --felony-jail-time "3 minutes" \
      --init-voting-delay "1 minutes / BLOCK_INTERVAL" \
      --init-voting-period "2 minutes / BLOCK_INTERVAL" \
      --init-min-period-after-quorum "uint64(1 minutes / BLOCK_INTERVAL)" \
      --governor-protector "0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186" \
      --init-minimal-delay "1 minutes"
}

function initNetwork() {
    cd ${workspace}
    "${workspace}"/bin/geth init-network --init.dir "${workspace}"/.local/bsc --init.size=${size} --config "${workspace}"/config.toml "${workspace}"/genesis/genesis.json
    rm -rf "${workspace}"/*bsc.log*
    for ((i = 0; i < size; i++)); do
        sed -i -e '/"<nil>"/d' "${workspace}"/.local/bsc/node${i}/config.toml
        cp -R "${workspace}"/.local/bsc/validator${i}/keystore "${workspace}"/.local/bsc/node${i}

        cp "${workspace}"/bin/geth "${workspace}"/.local/bsc/node${i}/geth${i}
        # init genesis
        initLog=${workspace}/.local/bsc/node${i}/init.log
        "${workspace}"/.local/bsc/node${i}/geth${i} --datadir "${workspace}"/.local/bsc/node${i} init --state.scheme ${stateScheme} "${workspace}"/genesis/genesis.json  > "${initLog}" 2>&1
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
          --from-file ${workspace}/.local/bsc/.local/bsc/node${i}/config.toml \
          --from-file ${workspace}/genesis/genesis.json

        kubectl delete configmap nodekey${i} -n bsc
        kubectl create configmap nodekey${i} -n bsc \
          --from-file ${workspace}/.local/bsc/.local/bsc/node${i}/geth/nodekey
    done

}

function initNetwork_k8s() {
   cd ${workspace}
   "${workspace}"/bin/geth init-network --init.dir "${workspace}"/.local/bsc --init.ips=${ips_string} --init.size=${size} --config "${workspace}"/config.toml "${workspace}"/genesis/genesis.json
    for ((i = 0; i < size; i++));do
        sed -i -e '/"<nil>"/d' "${workspace}"/.local/bsc/node${i}/config.toml

        staticPeers=$(generate_static_peers ${size} ${i})
        line=$(grep -n -e 'StaticNodes' "${workspace}"/.local/bsc/node${i}/config.toml | cut -d : -f 1)
        head -n $((line-1)) "${workspace}"/.local/bsc/node${i}/config.toml >> "${workspace}"/.local/bsc/node${i}/config.toml-e
        echo "StaticNodes = [${staticPeers}]" >> "${workspace}"/.local/bsc/node${i}/config.toml-e
        tail -n +$(($line+1)) "${workspace}"/.local/bsc/node${i}/config.toml >> "${workspace}"/.local/bsc/node${i}/config.toml-e
        rm -f "${workspace}"/.local/bsc/node${i}/config.toml
        mv "${workspace}"/.local/bsc/node${i}/config.toml-e "${workspace}"/.local/bsc/node${i}/config.toml
    done
   rm -rf  "${workspace}"/*bsc.log*
}

function install_k8s() {
    for ((i = 0; i < size; i++));do
        helm install bsc-node-${i} \
          --namespace bsc --create-namespace \
          --set-string configName=config${i},secretName=keystore${i},nodeKeyCfgName=nodekey${i} \
          "${workspace}"/helm/bsc
    done
}

function uninstall_k8s() {
    for ((i=0;i<${size};i++));do
        helm uninstall bsc-node-${i} --namespace bsc
    done
}

function native_start() {
    hardforkTime=$(cat "${workspace}"/.local/bsc/hardforkTime.txt|grep hardforkTime|awk -F" " '{print $NF}')
    for ((i = 0; i < size; i++));do
        for j in "${workspace}"/.local/bsc/validator${i}/keystore/*;do
            cons_addr="0x$(cat ${j} | jq -r .address)"
        done

        HTTPPort=$((8545 + i))
        WSPort=${HTTPPort}
        MetricsPort=$((6060 + i))
        P2PPort=$((30311 + i))

        sed -i -e "s/30311/${P2PPort}/g" "${workspace}"/.local/bsc/node${i}/config.toml

        initLog=${workspace}/.local/bsc/node${i}/init.log
        rialtoHash=`cat ${initLog}|grep "database=lightchaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`

        # run BSC node
        nohup  "${workspace}"/.local/bsc/node${i}/geth${i} --config "${workspace}"/.local/bsc/node${i}/config.toml \
            --datadir "${workspace}"/.local/bsc/node${i} \
            --password "${workspace}"/.local/bsc/password.txt \
            --blspassword "${workspace}"/.local/bsc/password.txt \
            --nodekey "${workspace}"/.local/bsc/node${i}/geth/nodekey \
            -unlock ${cons_addr} --miner.etherbase ${cons_addr} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
            --ws.addr 0.0.0.0 --ws.port ${WSPort} --http.addr 0.0.0.0 --http.port ${HTTPPort} --http.corsdomain "*" \
            --metrics --metrics.addr localhost --metrics.port ${MetricsPort} --metrics.expensive \
            --gcmode archive --syncmode full --state.scheme ${stateScheme} --mine --vote --monitor.maliciousvote \
            --rialtohash ${rialtoHash} --override.shanghai ${hardforkTime} --override.kepler ${hardforkTime} \
            --override.feynman ${hardforkTime} \
            > "${workspace}"/.local/bsc/node${i}/bsc-node.log 2>&1 &
    done
}

CMD=$1
case ${CMD} in
reset)
    exit_previous
    create_validator
    reset_genesis
    prepare_config
    initNetwork
    native_start
    ;;
start)
    native_start
    ;;
stop)
    exit_previous
    ;;
install_k8s)
    create_validator
    reset_genesis
    prepare_config
    initNetwork_k8s
    prepare_k8s_config
    install_k8s
    ;;
uninstall_k8s)
    uninstall_k8s
    ;;
*)
    echo "Usage: start_cluster.sh | reset | start | stop"
    ;;
esac
