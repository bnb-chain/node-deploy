#!/usr/bin/env bash

bin="reth-bsc"
service="reth-bsc-sentry"

service ${service} stop
cp /tmp/reth-bsc /server/sentry/${bin} && chmod u+x /server/sentry/${bin}
# update `config` in genesis.json
# /server/sentry/sentry dumpgenesis  --datadir /server/sentry/ > /server/sentry/genesis.json

#cd  /server/sentry/geth/
#rm -rf  chaindata  les.server  nodes  triecache

#sed -i -e 's/sleep 5/sleep 40/' /server/sentry/chaind.sh

#/server/sentry/sentry init --datadir /server/sentry/ /server/sentry/genesis.json

#sed -i -e 's/HTTPModules = \[/HTTPModules = \["debug",/g' /server/sentry/config.toml
#sed -i -e 's/GlobalSlots = 10000/GlobalSlots = 10000/g' /server/sentry/config.toml
#sed -i -e 's/GlobalQueue = 5000/GlobalQueue = 5000/g' /server/sentry/config.toml
#sed -i -e 's/Level = "info"/Level = "debug"/g' /server/sentry/config.toml
#sed -i -e 's/GasCeil = 30000000/GasCeil = 60000000/g' /server/sentry/config.toml

service ${service} start