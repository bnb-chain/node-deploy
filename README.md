## Deployment tools of BC-BSC

#### Preparation

1. Make sure `git`,`solc`, `nodejs`, `npm`, `helm` is well installed. 
- solc: 0.6.4 
- nodejs: v12.18.3 
- npm: 6.14.6 
- helm: v3.9.4+ 

2. For the first time, please execute:
```bash
$ git submodule update --init --recursive
```

3. Make `geth`, `bnbchaind`, `bnbcli` binary, and put it into `bin/` folder.

#### Setup All
```
bash +x ./setup_bc_node.sh init
bash +x ./setup_bc_node.sh install_k8s
kubectl port-forward svc/bc-node 26657:26657 -n bc

bash +x ./setup_bsc_node.sh register
bash +x ./setup_bsc_node.sh generate
bash +x ./setup_bsc_node.sh install_k8s

bash +x ./setup_oracle_relayer.sh docker
bash +x ./setup_oracle_relayer.sh install_k8s

bash +x ./setup_bsc_relayer.sh docker
bash +x ./setup_bsc_relayer.sh install_k8s
```
