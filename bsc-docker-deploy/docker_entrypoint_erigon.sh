#!/bin/bash
set -e

# init genesis
/app/bin/erigon init --datadir /app /app/genesis.json && \
echo "================================================================================="
/app/bin/erigon --datadir /app --chain=default \
    --http \
    --http.api eth,admin,erigon,net \
    --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain "*" \
     --bootnodes "${BOOTNODES}" \
     --networkid 714 \
     --port 30311 \
     --p2p.protocol 66 \
     --db.pagesize "16k" \
     --db.size.limit "200GB" \
     --snapshots false \
     --private.api.addr localhost:9090 \
     --nodediscovery \
     --metrics   --metrics.addr 0.0.0.0  --metrics.port 6060 \
     --log.console.verbosity 4 \
     --nat any &

sleep 5 # sleep a bit until the log file is created

exec tail -f /app/logs/erigon.log