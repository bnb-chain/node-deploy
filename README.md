# Deployment tools of BSC


## Installation
Before proceeding to the next steps, please ensure that the following packages and softwares are well installed in your local machine: 
- nodejs: 12.18.3 
- npm: 6.14.6
- go: 1.18+
- foundry
- python3
- poetry
- jq

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
pip3 install -r requirements.txt
```

3. Make `geth`, `bootnode` binary files, and put them into `bin/` folder.
```bash
git clone https://github.com/bnb-chain/bsc.git
cd bsc && make geth
go build -o ./build/bin/bootnode ./cmd/bootnode

cp ./build/bin/geth ../bin/geth
cp ./build/bin/bootnode ../bin/bootnode
```

4. Configure the cluster
```
  You can configure the cluster by modifying the following files:
   - `config.toml`
   - `genesis/genesis-template.json`
   - `.env`
```

5. Setup all nodes.
two different ways, choose as you like.
```bash
#native deploy without docker
bash -x ./start_cluster.sh reset # will reset the cluster and start
bash -x ./start_cluster.sh stop  # only stop the cluster
bash -x ./start_cluster.sh start # only start the cluster
bash -x ./start_cluster.sh restart # start the cluster after stopping it
```

```bash
#on k8s environment
minikube start
bash -x ./start_cluster.sh install_k8s
kubectl -n bsc port-forward svc/bsc-node-0 8545:8545
```


## Background transactions
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