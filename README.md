# Deployment tools of BSC


## Installation
Before proceeding to the next steps, please ensure that the following packages and softwares are well installed in your local machine: 
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
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
```

3. build `create-validator`

```bash
# This tool is used to register the validators into StakeHub.
cd create-validator
go build
```

4. Configure the cluster

Copy the example env file and edit it to match your setup:
```bash
cp .env.example .env
```

You can configure the cluster by modifying the following files:
   - `.env`
   - `config.toml`
   - `genesis/genesis-template.json`
   - `genesis/scripts/init_holders.template`

**Reth-BSC Configuration:**
To use reth-bsc nodes instead of geth nodes for some validators, configure the following in `.env`:
```bash
# Path to the reth-bsc binary
RETH_BSC_BINARY_PATH="/path/to/reth-bsc/target/debug/reth-bsc"

# Number of nodes to run with reth-bsc (starting from node0)
# For example: RETH_NODE_COUNT=2 will run node0 and node1 with reth-bsc, others with geth
RETH_NODE_COUNT=1
```

Reth-BSC nodes are launched with BLS vote key CLI flags by default:
- `--bls.keystore-path` and `--bls.keystore-password` are auto-detected from each node’s `bls/keystore` and `${KEYPASS}`.
- To override, set either of the following envs before start (the script will pass them as CLI, which takes precedence over env inside reth):
  - `BSC_BLS_PRIVATE_KEY` (dev only) → passes `--bls.private-key`
  - `BSC_BLS_KEYSTORE_PATH` and `BSC_BLS_KEYSTORE_PASSWORD` → passes `--bls.keystore-path` and `--bls.keystore-password`


5. Prepare the `bin/` directory for the geth binary.

If `useLatestBscClient=true` in `.env` (the default), the `reset` command builds geth from source and moves it into `bin/`. The `bin/` directory must exist first or the move will fail:
```bash
mkdir -p bin
```

If you already have a pre-built geth binary (e.g. from a previous build at `bsc/build/bin/geth`), you can copy it directly instead of waiting for a full rebuild:
```bash
mkdir -p bin && cp bsc/build/bin/geth bin/geth
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

## Prometheus metrics

reth-bsc nodes expose Prometheus metrics automatically when running via `bsc_cluster.sh`.

**Ports:**
- reth-bsc nodes: `9001 + nodeIndex * 2` (node0=9001, node1=9003, node2=9005, …)
- geth nodes: `6060 + nodeIndex * 2` (node0=6060, node1=6062, node2=6064, …)

A `prometheus.yml` is included that scrapes all nodes. Run Prometheus with Docker:

```bash
cd /path/to/node-deploy
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

Then open [http://localhost:9090/graph](http://localhost:9090/graph).

> **macOS note:** `--network host` does not work on macOS. The `prometheus.yml` uses
> `host.docker.internal` to reach node metrics running on your Mac.

To also spin up Grafana alongside it:

```bash
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana
```

Grafana will be available at [http://localhost:3000](http://localhost:3000) (admin/admin). Add Prometheus as a datasource using `http://host.docker.internal:9090`.

> If you change `BSC_CLUSTER_SIZE` in `.env`, add or remove the corresponding target ports in `prometheus.yml`.

## Heap profiling for reth-bsc nodes

reth-bsc nodes can be profiled using jemalloc's built-in heap profiler.

> **Note:** Before building with profiling support, the `reth-bsc` repo requires two small
> pending changes that have not yet been pushed upstream. See
> [reth-bsc-pending-changes.md](reth-bsc-pending-changes.md) for the exact edits needed.

### 1. Build reth-bsc with profiling support

```bash
cd /path/to/reth-bsc
cargo build --bin reth-bsc --profile profiling --features jemalloc-prof,asm-keccak
```

### 2. Configure node-deploy

In `.env`, point to the profiling binary and set `RETH_JEMALLOC_PROF`:

```bash
RETH_BSC_BINARY_PATH="/path/to/reth-bsc/target/profiling/reth-bsc"

# lg_prof_interval:30 dumps every ~1 GB allocated; prof_final:true dumps on exit
RETH_JEMALLOC_PROF="prof:true,prof_active:true,lg_prof_sample:19,lg_prof_interval:30,prof_final:true,prof_prefix:/tmp/reth-heap."
```

Leave `RETH_JEMALLOC_PROF` unset to run without profiling overhead.

> **Note:** tikv-jemallocator uses the `_rjem_` symbol prefix, so the script passes
> `_RJEM_MALLOC_CONF` to the process (not `MALLOC_CONF`). Setting `MALLOC_CONF`
> directly will have no effect.

### 3. Start the cluster

```bash
bash -x ./bsc_cluster.sh reset
```

Heap dumps are written to the path specified by `prof_prefix`, e.g. `/tmp/reth-heap.<pid>.<seq>.heap`.

### 4. Read the heap dumps

`jeprof` is compiled as part of the reth-bsc build:

```bash
export JEPROF=/path/to/reth-bsc/target/profiling/build/tikv-jemalloc-sys-*/out/build/bin/jeprof
export BINARY=/path/to/reth-bsc/target/profiling/reth-bsc
chmod +x $JEPROF
```

Generate a flamegraph SVG (requires `brew install graphviz`):

```bash
$JEPROF --svg $BINARY /tmp/reth-heap.<pid>.<seq>.heap > heap.svg && open heap.svg
```

Compare two dumps to see allocation growth between them:

```bash
$JEPROF --svg --base=/tmp/reth-heap.<pid>.1.heap $BINARY /tmp/reth-heap.<pid>.2.heap > diff.svg && open diff.svg
```

Top allocations as text:

```bash
$JEPROF --text $BINARY /tmp/reth-heap.<pid>.<seq>.heap
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
