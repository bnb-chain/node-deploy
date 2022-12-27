## Deployment tools of BC-BSC

#### Preparation

1. Make sure `git`,`solc`, `nodejs`, `npm`, `helm`, `jq`, `go` is well installed. 
- solc: 0.6.4 
- nodejs: v12.18.3 
- npm: 6.14.6 
- helm: v3.9.4+ 
- go: 1.18

2. For the first time, please execute:
```bash
git submodule update --init --recursive
```

3. Make `geth`, `bnbchaind`, `bnbcli` binary, and put it into `bin/` folder.
```bash
git clone https://github.com/bnb-chain/bsc.git
cd bsc && make geth
cp ./build/bin/geth ../bin/geth

git clone https://github.com/bnb-chain/node.git
cd node && make build
cp ./build/bnbcli ../bin/bnbcli
cp ./build/bnbchaind ../bin/bnbchaind
```

4. Make `tool` binary
```bash
make tool
```

#### Setup All
```
bash +x ./setup_bc_node.sh init
bash +x ./setup_bc_node.sh install_k8s
kubectl port-forward svc/bc-node 26657:26657 -n bc

bash +x ./setup_bsc_node.sh register
password -> 12345678
bash +x ./setup_bsc_node.sh generate
bash +x ./setup_bsc_node.sh install_k8s

bash +x ./setup_oracle_relayer.sh docker
bash +x ./setup_oracle_relayer.sh install_k8s

bash +x ./setup_bsc_relayer.sh docker
bash +x ./setup_bsc_relayer.sh install_k8s
```

#### Remove All
```bash
bash +x ./setup_bc_node.sh uninstall_k8s
bash +x ./setup_bsc_node.sh uninstall_k8s
bash +x ./setup_oracle_relayer.sh uninstall_k8s
bash +x ./setup_bsc_relayer.sh uninstall_k8s
```

#### Cross Chain Tx
1. send bnb from bc to bsc
```bash
## macos
./bin/bnbcli bridge transfer-out --amount 5000000000000:BNB --expire-time $(date -v+300S +%s) --to 0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186  --from local-user --chain-id Binance-Chain-Nile --node localhost:26657

## linux
./bin/bnbcli bridge transfer-out --amount 5000000000000:BNB --expire-time $(date --date="+300 seconds" +%s) --to 0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186  --from local-user --chain-id Binance-Chain-Nile --node localhost:26657
```

2. Enable port forwarding
```
kubectl -n bsc port-forward po/bsc-node-0 8545:8545
```

3. Check the balance 
```
curl -X POST "http://127.0.0.1:8545" -H "Content-Type: application/json"  --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186", "latest"],"id":1}' 
```

#### Tools
1. [solc-select](https://github.com/crytic/solc-select)
2. [nvm](https://github.com/nvm-sh/nvm)
3. [len](https://k8slens.dev/)
4. [minikube](https://minikube.sigs.k8s.io/docs/start/)
