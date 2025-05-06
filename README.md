# Deployment tools of BSC


## Installation
Before proceeding to the next steps, please ensure that the following packages and softwares are well installed in your local machine: 
- nodejs: 18.20.2 
- npm: 6.14.6
- go: 1.18+
- foundry
- python3 3.12+
- poetry
- jq


## Quick Start
1. Clone this repository
```bash
git clone https://github.com/bnb-chain/node-deploy.git
```

2. For the first time, please execute the following command
```bash
pip3 install -r requirements.txt
```

3. Make `geth` binary files, and put it into `bin/` folder.
```bash
git clone https://github.com/bnb-chain/bsc.git
cd bsc && make geth
go build -o ./build/bin/bootnode ./cmd/bootnode
```

4. build `create-validator`

```bash
# This tool is used to register the validators into StakeHub.
cd create-validator
go build
```

5. Configure the cluster
```
  You can configure the cluster by modifying the following files:
   - `config.toml`
   - `genesis/genesis-template.json`
   - `.env`
```

6. Setup all nodes.
two different ways, choose as you like.
```bash
bash -x ./bsc_cluster.sh reset # will reset the cluster and start
# The 'vidx' parameter is optional. If provided, its value must be in the range [0, ${BSC_CLUSTER_SIZE}). If omitted, it affects all clusters.
bash -x ./bsc_cluster.sh stop [vidx] # Stops the cluster
bash -x ./bsc_cluster.sh start [vidx] # only start the cluster
bash -x ./bsc_cluster.sh restart [vidx] # start the cluster after stopping it
```

7. Setup a full node.
If you want to run a full node to test snap/full syncing, you can run:

> Attention: it relies on the validator cluster, so you should set up validators by `bsc_cluster.sh` firstly.

```bash
# start a full sync node0
bash +x ./bsc_fullnode.sh start 0 full
# start a snap sync node1
bash +x ./bsc_fullnode.sh start 1 snap
# restart the snap sync node1
bash +x ./bsc_fullnode.sh restart 1 snap
# stop the snap sync node1
bash +x ./bsc_fullnode.sh stop 1 snap
# clean the snap sync node1
bash +x ./bsc_fullnode.sh clean 1 snap
# start a snap sync node as fast node
bash +x ./bsc_fullnode.sh start 2 snap "--tries-verify-mode none"
# start a snap sync node with prune ancient
bash +x ./bsc_fullnode.sh start 3 snap "--pruneancient"
# start pruneblock for a node
bash +x ./bsc_fullnode.sh pruneblock 3 snap
```

You can see the logs in `.local/bsc/fullnode`.

Generally, you need to wait for the validator to produce a certain amount of blocks before starting the full/snap syncing test, such as 1000 blocks.

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