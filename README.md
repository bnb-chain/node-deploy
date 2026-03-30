# Deployment tools of BSC


## Installation
Before proceeding to the next steps, please ensure that the following packages and softwares are well installed in your local machine: 

> [!TIP]
> **Don't want to install these manually?** You can skip to the [Docker Version](#docker-version-recommended) section at the bottom of this file.

- nodejs: v16.15.0
- npm: 6.14.6
- go: 1.24+
- foundry
- python3 3.12.x
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

3. build `create-validator`

```bash
# This tool is used to register the validators into StakeHub.
cd create-validator
go build
```

4. Configure the cluster
```
  You can configure the cluster by modifying the following files:
   - `config.toml`
   - `genesis/genesis-template.json`
   - `genesis/scripts/init_holders.template`
   - `.env`
```

5. Setup all nodes.
two different ways, choose as you like.
```bash
bash -x ./bsc_cluster.sh reset # will reset the cluster and start
# The 'vidx' parameter is optional. If provided, its value must be in the range [0, ${BSC_CLUSTER_SIZE}). If omitted, it affects all clusters.
bash -x ./bsc_cluster.sh stop [vidx] # Stops the cluster
bash -x ./bsc_cluster.sh start [vidx] # only start the cluster
bash -x ./bsc_cluster.sh restart [vidx] # start the cluster after stopping it
```

6. Setup a full node.
If you want to run a full node to test snap/full syncing, you can run:

> Attention: it relies on the validator cluster, so you should set up validators by `bsc_cluster.sh` firstly.

```bash
# reset a full sync node0
bash +x ./bsc_fullnode.sh reset 0 full
# reset a snap sync node1
bash +x ./bsc_fullnode.sh reset 1 snap
# restart the snap sync node1
bash +x ./bsc_fullnode.sh restart 1 snap
# stop the snap sync node1
bash +x ./bsc_fullnode.sh stop 1 snap
# clean the snap sync node1
bash +x ./bsc_fullnode.sh clean 1 snap
# reset a full sync node as fast node
bash +x ./bsc_fullnode.sh reset 2 full "--tries-verify-mode none"
# reset a snap sync node with prune ancient
bash +x ./bsc_fullnode.sh reset 3 snap "--pruneancient"
```

You can see the logs in `.local/fullnode`.

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

## Docker Version (Recommended)

If you don't want to install all dependencies manually on your Mac/PC, you can use the Dockerized toolbox:

1. **Build and Start Toolbox**:
   This command builds the environment, compiles the `create-validator` tool, and **automatically initializes** the BSC cluster.

   ```bash
   docker compose up -d --build
   ```

2. **Enter the Container**:
   Once the cluster is initialized (you can check `docker logs -f bsc-toolbox`), enter the container to use the development tools:

   ```bash
   docker exec -it bsc-toolbox bash
   ```

3. **Validator Tool**:
   The `create-validator` tool is pre-built and installed at `/usr/local/bin/create-validator`. You can run it from anywhere inside the container.

4. **Observe from Host (Mac)**:
   Access RPC at `http://localhost:8545`.

### Common Observation Commands (Inside Container)

Here are some useful commands to monitor the cluster:

- **Check Block Height**:
  `geth --exec "eth.blockNumber" attach .local/node0/geth.ipc`
- **List P2P Peers**:
  `geth --exec "admin.peers" attach .local/node0/geth.ipc`
- **Check Node Info**:
  `geth --exec "admin.nodeInfo" attach .local/node0/geth.ipc`
- **Tail Logs**:
  `tail -f .local/node0/bsc-node.log`

### Monitoring and Metrics

The cluster is configured to expose internal metrics for monitoring. These are accessible from your **(Host)**:

- **Prometheus Metrics**: `http://localhost:6060/debug/metrics/prometheus`
- **JSON Metrics**: `http://localhost:6060/debug/metrics`
- **Performance Profiling (pprof)**: `http://localhost:7060/debug/pprof/`

**Port Mapping for Nodes:**

| Node | RPC (HTTP/WS) | Metrics (Prometheus) | pprof (Debug) |
| :--- | :--- | :--- | :--- |
| **Node 0** | 8545 | 6060 | 7060 |
| **Node 1** | 8547 | 6062 | 7062 |
| **Node 2** | 8549 | 6064 | 7064 |
| **Node 3** | 8551 | 6066 | 7066 |

### Storage Optimization

To prevent rapid disk space exhaustion during local testing, this setup uses the following optimizations:

- **DB Engine**: Forced to `leveldb` (more space-efficient than Pebble for small clusters).
- **State Scheme**: Set to `hash` to significantly reduce state storage size compared to the default path-based scheme.
- **Auto-Reset**: The `docker compose up` command triggers a full reset by default, ensuring you always start with a clean state.