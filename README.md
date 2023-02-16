## Deployment tools of BC-BSC

## Installation

Before proceeding to the next steps, please ensure that the following packages and softwares are well installed in your local machine: 
- solc: 0.6.4
- nodejs: 12.18.3 
- npm: 6.14.6
- helm: 3.9.4
- go: 1.18
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

3. Make `geth`, `bootnode`, `bnbchaind`, `bnbcli` binary files, and put them into `bin/` folder.
```bash
git clone https://github.com/bnb-chain/bsc.git
cd bsc && make geth
go build -o ./build/bin/bootnode ./cmd/bootnode

cp ./build/bin/geth ../bin/geth
cp ./build/bin/bootnode ../bin/bootnode

git clone https://github.com/bnb-chain/node.git
cd node && make build
cp ./build/bnbcli ../bin/bnbcli
cp ./build/bnbchaind ../bin/bnbchaind
```

4. Make `tool` binary
```bash
make tool
```

5. Start local Kubernetes cluster
```bash
minikube start
```

6. Setup all nodes on k8s environment
```bash
bash +x ./setup_bc_node.sh init
bash +x ./setup_bc_node.sh install_k8s
kubectl port-forward svc/bc-node-0 26657:26657 -n bc

bash +x ./setup_bsc_node.sh register
bash +x ./setup_bsc_node.sh generate
bash +x ./setup_bsc_node.sh install_k8s

bash +x ./setup_oracle_relayer.sh docker
bash +x ./setup_oracle_relayer.sh install_k8s

bash +x ./setup_bsc_relayer.sh docker
bash +x ./setup_bsc_relayer.sh install_k8s
```

7. Execute cross chain transaction by sending BNB from BC to BSC
```bash
## macos
echo "12345678" | ./bin/bnbcli bridge transfer-out --amount 50000:BNB --expire-time $(date -v+300S +%s) --to 0x96D904C0e47e6477C4416369a9858f6E57B317eC  --from node0-delegator --chain-id Binance-Chain-Nile --node localhost:26657 --home ./.local/bc/node0

## linux
echo "12345678" | ./bin/bnbcli bridge transfer-out --amount 50000:BNB --expire-time $(date --date="+300 seconds" +%s) --to 0x96D904C0e47e6477C4416369a9858f6E57B317eC  --from local-user --chain-id Binance-Chain-Nile --node localhost:26657
```

8. Enable port forwarding
```
kubectl -n bsc port-forward svc/bsc-node-0 8545:8545
```

9. Check the account balance
```
curl -X POST "http://127.0.0.1:8545" -H "Content-Type: application/json"  --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x96D904C0e47e6477C4416369a9858f6E57B317eC", "latest"],"id":1}' 
```

## Additional Commands

#### Remove all nodes
```bash
bash +x ./setup_bc_node.sh uninstall_k8s
bash +x ./setup_bsc_node.sh uninstall_k8s
bash +x ./setup_oracle_relayer.sh uninstall_k8s
bash +x ./setup_bsc_relayer.sh uninstall_k8s
```

#### Upgrade image
```bash
kubectl set image statefulset/bc-node-0 bc=ghcr.io/bnb-chain/node:0.10.6 -n bc
...

kubectl set image statefulset/bsc-node-0 bsc=ghcr.io/bnb-chain/bsc:1.1.18_hf -n bsc
...
```