## Prepare BC
```
mkdir -p ./.local/bc
rm -rf ./.local/bc/*
bnbchaind init --home ./.local/bc --chain-id local-testnet --moniker test1 --kpass "12345678" > ./.local/bc/info


kubectl create ns bc
kubectl delete secret keyfile -n bc
kubectl create secret generic keyfile -n bc \
 --from-file .local/bc/config/node_key.json \
 --from-file .local/bc/config/priv_validator_key.json

kubectl delete configmap configs -n bc
kubectl create configmap configs -n bc \
 --from-file .local/bc/config/app.toml \
 --from-file .local/bc/config/config.toml \
 --from-file .local/bc/config/genesis.json 

helm install bc-node \
    --namespace bc --create-namespace \
    ./helm/bc

```

## Register validator on BC

```
./bin/geth account new --datadir ./.local/bsc/validator


./bin/bnbcli staking bsc-create-validator \
--side-cons-addr "0x56cF6C1EF1315b2fE7b549c87BBe7851F14F0C44" \
--side-fee-addr "0x43e44a05ecf8316e254b4aa1ca1c82c5ccd213b9" \
--address-delegator "bnb1340263fqudxd69sny6adfksucmtxpmpvtg652l" \
--side-chain-id rialto \
--amount 10000000000000:BNB \
--commission-rate 10000000 \
--commission-max-rate 20000000 \
--commission-max-change-rate 5000000 \
--moniker "local-test" \
--details "local test" \
--website "http://localhost" \
--from test1 \
--chain-id local-testnet \
--node http://localhost:26657
```

## Prepare BSC
```

kubectl create ns bsc
kubectl delete secret keystore -n bsc
files="" && for i in .local/bsc/validator/keystore/*; do; files="$files --from-file=$i"; done && bash -c "kubectl create secret generic keystore -n bsc ${files}"

kubectl delete secret password -n bsc
kubectl create secret generic password -n bsc \
 --from-file .local/bsc/validator/password.txt

kubectl delete configmap configs -n bsc
kubectl create configmap configs -n bsc \
 --from-file .local/bsc/clusterNetwork/node0/config.toml

helm install bsc-node \
    --namespace bsc --create-namespace \
    ./helm/bsc
```

## Prepare Oracle Relayer
```
git clone https://github.com/bnb-chain/oracle-relayer
cd oracle-relayer
go get -u golang.org/x/sys # fix compile issue
make build_docker

mkdir -p .local/relayer/
rm -rf .local/relayer/oracle_relayer.*
cp oracle_relayer.template .local/relayer/oracle_relayer.json
bsc_chain_id=777
sed -i -e "s/{{bsc_chain_id}}/${bsc_chain_id}/g" .local/relayer/oracle_relayer.json
mnemonic=$(cat .local/bc/info | jq .app_message.secret)
sed -i -e "s/{{bbc_mnemonic}}/${mnemonic}/g" .local/relayer/oracle_relayer.json

kubectl create ns relayer
kubectl create configmap oracle-relayer -n relayer \
 --from-file .local/relayer/oracle_relayer.json

helm install oracle-relayer \
    --namespace relayer --create-namespace \
    ./helm/oracle-relayer
```
0x24b498617c81fdb3a9b991eab1b8cd1fe038501714524087c744902d14088c11

## Prepare BSC Relayer
```
git clone https://github.com/bnb-chain/bsc-relayer
cd bsc-relayer
go get -u golang.org/x/sys # fix compile issue
docker build . -t bsc-relayer

bsc_chain_id=777
mnemonic=$(cat .local/bc/info | jq .app_message.secret)
private_key="59ba8068eb256d520179e903f43dacf6d8d57d72bd306e1bd603fdb8c8da10e8" ## initHolder

mkdir -p .local/relayer/
rm -rf .local/relayer/bsc_relayer.*
cp bsc_relayer.template .local/relayer/bsc_relayer.json
sed -i -e "s/{{bsc_chain_id}}/${bsc_chain_id}/g" .local/relayer/bsc_relayer.json
sed -i -e "s/{{bbc_mnemonic}}/${mnemonic}/g" .local/relayer/bsc_relayer.json
sed -i -e "s/{{private_key}}/${private_key}/g" .local/relayer/bsc_relayer.json

kubectl create ns relayer
kubectl create configmap bsc-relayer -n relayer \
 --from-file .local/relayer/bsc_relayer.json

helm install bsc-relayer \
    --namespace relayer --create-namespace \
    ./helm/bsc-relayer
```

## Uninstall
```
helm uninstall bc-node -n bc
helm uninstall bsc-node -n bsc
helm uninstall bsc-relayer -n relayer
helm uninstall oracle-relayer -n relayer
```