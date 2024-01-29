## Deployment tools of BC-BSC

## Installation

Before proceeding to the next steps, please ensure that the following packages and software are well installed in your local machine: 
- foundry
- python3
- nodejs
- expect
- jq

If you are going to set up nodes on k8s environment, the following packages and software are necessary:
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

git submodule update --init --recursive
cd genesis
npm install
forge install --no-git --no-commit foundry-rs/forge-std@v1.7.3
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
   
  You can configure the cluster by modifying the following files:
   - `genesis/genesis-template.json`
   - `.env`

5. Setup all nodes.
two different ways, choose as you like.

**On Kubernetes environment**

```bash
#on k8s environment
minikube start

bash +x ./start_cluster.sh generate
bash +x ./start_cluster.sh install_k8s
kubectl -n bsc port-forward svc/bsc-node-0 8545:8545
```

**Natively**
```bash
#native deploy without docker
bash +x ./start_cluster.sh start 
```

## Background transactions

```bash
cd txbot
go build
./air-drops
```
