#!/usr/bin/env bash

service bsc stop
cp /tmp/bsc /server/validator/bsc

#cd  /server/validator/geth/
#rm -rf  chaindata  les.server  nodes  triecache

#sed -i -e 's/sleep 5/sleep 40/' /server/validator/chaind.sh

#/server/validator/bsc init --datadir /server/validator/ /server/validator/genesis.json

#sed -i -e 's/HTTPModules = \[/HTTPModules = \["debug",/g' /server/validator/config.toml

service bsc start