#!/bin/bash
set -e

# copy keys
cp /data/keys/password.txt /app
cp /data/genesis.json /app
cp -R /data/keys/${AUTHORITY_NAME}/bls /app
cp -R /data/keys/${AUTHORITY_NAME}/consensus/keystore /app


CONS_ADDR="0x$(cat keystore/* | jq -r .address)"

# init genesis
/app/bin/geth init --datadir /app /app/genesis.json && \
rm -f /app/geth/nodekey && \
cp /data/keys/${AUTHORITY_NAME}/nodekey /app/geth/nodekey && \
/app/bin/geth --config /app/config.toml \
    --datadir /app \
    --password /app/password.txt \
    --blspassword /app/password.txt \
    --nodekey /app/geth/nodekey \
    -unlock ${CONS_ADDR} --rpc.allow-unprotected-txs --allow-insecure-unlock  \
    --miner.etherbase ${CONS_ADDR} \
    --ws.addr 0.0.0.0 --ws.port 8545 --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain "*" \
    --metrics --metrics.addr 0.0.0.0 --metrics.port 6060 --metrics.expensive \
    --gcmode archive --syncmode=full --mine --vote --monitor.maliciousvote \
    --port 30311 \
    --bootnodes "${BOOTNODES}" \
    --log.vmodule=eth=5,p2p=5 \
    > /app/bsc-node.log 2>&1 &

sleep 4

exec tail -f /app/bsc-node.log
