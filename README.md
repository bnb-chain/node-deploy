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

6. Setup a full node.
If you want to run a full node to test snap/full syncing, you can run:

> Attention: it relies on the validator cluster, so you should set up validators by `start_cluster.sh` first.

```bash
# start a full sync node0
bash +x ./start_fullnode.sh start 0 full
# start a snap sync node1
bash +x ./start_fullnode.sh start 1 snap
# restart the snap sync node1
bash +x ./start_fullnode.sh restart 1 snap
# stop the snap sync node1
bash +x ./start_fullnode.sh stop 1 snap
# clean the snap sync node1
bash +x ./start_fullnode.sh clean 1 snap
# start a snap sync node as fast node
bash +x ./start_fullnode.sh start 2 snap "--tries-verify-mode none"
# start a snap sync node with prune ancient
bash +x ./start_fullnode.sh start 3 snap "--pruneancient"
# start pruneblock for a node
bash +x ./start_fullnode.sh pruneblock 3 snap
```

You can see the logs in `.local/bsc/fullnode`.

Generally, you need to wait for the validator to produce a certain amount of blocks before starting the full/snap syncing test, such as 1000 blocks.

7. setup grafana monitor

you must install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) first.

```bash
cd monitor
docker-compose up -d
```

If all goes well, you can visit grafana in [http://127.0.0.1:3000/](http://127.0.0.1:3000/), default user/password is 'admin/admin'.

Then you need import the dashboard in `monitor/dashboard/validator-monitor-1712916445176.json`.

If you want to modify prometheus's config to add more bsc nodes, you can modify in here, `monitor/prometheus/prometheus.yml`. And restart it by `docker-compose restart prometheus`.

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