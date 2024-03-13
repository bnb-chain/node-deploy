## Deployment tools of BC-BSC

## Installation

Before proceeding to the next steps, please ensure that the following packages and softwares are well installed in your local machine: 
- solc: 0.6.4
- nodejs: 12.18.3 
- npm: 6.14.6
- go: 1.18+
- python: 3.8+
- expect
- foundry
- jq
- poetry

If you would setup nodes on k8s environment, the following packages and softwares are necessary:
- helm: 3.9.4
- minikube: 1.29.0
- docker: 20.10.22
- kubectl: 1.26.1


## Quick Start
1. Clone this repository
```bash
git clone https://github.com/bnb-chain/node-deploy.git
```

2. For the first time, please execute the following command
```bash
git submodule update --init --recursive
```

3. Make `geth`, `bootnode`, `bnbchaind`, `tbnbcli` binary files, and put them into `bin/` folder.
```bash
git clone https://github.com/bnb-chain/bsc.git
cd bsc && make geth
go build -o ./build/bin/bootnode ./cmd/bootnode

cp ./build/bin/geth ../bin/geth
cp ./build/bin/bootnode ../bin/bootnode

git clone https://github.com/bnb-chain/node.git
cd node && make build
cp ./build/tbnbcli ../bin/tbnbcli
cp ./build/bnbchaind ../bin/bnbchaind

git clone git@github.com:bnb-chain/test-crosschain-transfer.git
cd test-crosschain-transfer && go build
cp ./test-crosschain-transfer ../bin/test-crosschain-transfer
```

4. Make `tool` binary
```bash
make tool
```

5. Configure the cluster
   
  You can configure the cluster by modifying the following files:
   - `config.toml` 
   - `genesis/genesis-template.json`
   - `.env`

6. Setup all nodes.
two different ways, choose as you like.

**On Kubernetes environment**

```bash
#on k8s environment
minikube start

bash +x ./setup_bc_node.sh init
bash +x ./setup_bc_node.sh install_k8s
kubectl port-forward svc/bc-node-0 26657:26657 -n bc

bash +x ./setup_bsc_node.sh register
bash +x ./setup_bsc_node.sh generate_k8s
bash +x ./setup_bsc_node.sh install_k8s
kubectl -n bsc port-forward svc/bsc-node-0 8545:8545

bash +x ./setup_oracle_relayer.sh docker
bash +x ./setup_oracle_relayer.sh install_k8s

bash +x ./setup_bsc_relayer.sh docker
bash +x ./setup_bsc_relayer.sh install_k8s
```

**Natively**
```bash
#native deploy without docker
rm -rf .local

bash +x ./setup_bc_node.sh native_init 
bash +x ./setup_bc_node.sh native_start 

bash +x ./setup_bsc_node.sh native_init
bash +x ./setup_bsc_node.sh native_start

bash +x ./setup_bsc_relayer.sh native_init
bash +x ./setup_bsc_relayer.sh native_start 

bash +x ./setup_oracle_relayer.sh native_init
bash +x ./setup_oracle_relayer.sh native_start 
```

or simply
``` bash
# native deploy
bash +x ./start_cluster.sh
```

7. Execute cross chain transaction by sending BNB from BC to BSC
```bash
## 0x9fB29AAc15b9A4B7F17c3385939b007540f4d791 is the address used by test-crosschain-transfer as sender
## macos
echo "1234567890" | ./bin/tbnbcli bridge transfer-out --amount 500000000:BNB --expire-time $(date -v+300S +%s) --to 0x9fB29AAc15b9A4B7F17c3385939b007540f4d791  --from node0-delegator --chain-id Binance-Chain-Ganges --node localhost:26657 --home ./.local/bc/node0

## linux
echo "1234567890" | ./bin/tbnbcli bridge transfer-out --amount 500000000:BNB --expire-time $(date --date="+300 seconds" +%s) --to 0x9fB29AAc15b9A4B7F17c3385939b007540f4d791  --from local-user --chain-id Binance-Chain-Ganges --node localhost:26657
```

8. Check the account balance
```
curl -X POST "http://localhost:8545" -H "Content-Type: application/json"  --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x9fB29AAc15b9A4B7F17c3385939b007540f4d791", "latest"],"id":1}' 
```

## Additional Commands

#### Background transactions
```bash
## normal tx
cd txbot
go build
./air-drops

## blob tx
cd txblob
go build
./txblob
```

#### Remove all nodes
```bash
bash +x ./setup_bc_node.sh uninstall_k8s
bash +x ./setup_bsc_node.sh uninstall_k8s
bash +x ./setup_oracle_relayer.sh uninstall_k8s
bash +x ./setup_bsc_relayer.sh uninstall_k8s
```

```bash
bash +x ./setup_bc_node.sh native_stop 
bash +x ./setup_bsc_node.sh native_stop
bash +x ./setup_bsc_relayer.sh native_stop
bash +x ./setup_oracle_relayer.sh native_stop
```

or simply

```bash
bash +x ./stop_cluster.sh
```


### Start a standalone BSC Cluster

```bash
# one cmd to start bsc cluster all alone
bash +x ./setup_bsc_node.sh native_start_alone
```
#### Upgrade image
```bash
kubectl set image statefulset/bc-node-0 bc=ghcr.io/bnb-chain/node:0.10.6 -n bc
...

kubectl set image statefulset/bsc-node-0 bsc=ghcr.io/bnb-chain/bsc:1.1.18_hf -n bsc
...
```