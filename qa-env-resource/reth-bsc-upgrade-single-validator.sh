#!/usr/bin/env bash

bin="reth-bsc"
service="reth-bsc"

service ${service} stop
cp /tmp/${bin} /server/validator/${bin} && chmod u+x /server/validator/${bin}
# update `config` in genesis.json
# /server/validator/bsc dumpgenesis  --datadir /server/validator/ > /server/validator/genesis.json

#cd  /server/validator/geth/
#rm -rf  chaindata  les.server  nodes  triecache

#sed -i -e 's/sleep 5/sleep 40/' /server/validator/chaind.sh

#/server/validator/bsc init --datadir /server/validator/ /server/validator/genesis.json

#sed -i -e 's/HTTPModules = \[/HTTPModules = \["debug",/g' /server/validator/config.toml
#sed -i -e 's/GlobalSlots = 10000/GlobalSlots = 10000/g' /server/validator/config.toml
#sed -i -e 's/GlobalQueue = 5000/GlobalQueue = 5000/g' /server/validator/config.toml
#sed -i -e 's/Level = "info"/Level = "debug"/g' /server/validator/config.toml
#sed -i -e 's/GasCeil = 30000000/GasCeil = 60000000/g' /server/validator/config.toml

service ${service} start