#!/usr/bin/env bash

service bsc stop
cp /tmp/bsc /server/validator/bsc

#cd  /server/validator/geth/
#rm -rf  chaindata  les.server  nodes  triecache

#sed -i -e 's/sleep 5/sleep 40/' /server/validator/chaind.sh
#sed -i -e 's/FixedTurnLength=1/FixedTurnLength=4/' /server/validator/chaind.sh

#/server/validator/bsc init --datadir /server/validator/ /server/validator/genesis.json

#sed -i -e 's/HTTPModules = \[/HTTPModules = \["debug",/g' /server/validator/config.toml
#sed -i -e 's/GlobalSlots = 10000/GlobalSlots = 10000/g' /server/validator/config.toml
#sed -i -e 's/GlobalQueue = 5000/GlobalQueue = 5000/g' /server/validator/config.toml
#sed -i -e 's/Level = "info"/Level = "debug"/g' /server/validator/config.toml

service bsc start