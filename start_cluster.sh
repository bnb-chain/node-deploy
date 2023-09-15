#!/usr/bin/env bash
rm -rf .local

bash +x ./setup_bc_node.sh native_init 
bash +x ./setup_bc_node.sh native_start 

bash +x ./setup_bsc_node.sh native_init
bash +x ./setup_bsc_node.sh native_start

bash +x ./setup_bsc_relayer.sh native_init
bash +x ./setup_bsc_relayer.sh native_start 

bash +x ./setup_oracle_relayer.sh native_init
bash +x ./setup_oracle_relayer.sh native_start 