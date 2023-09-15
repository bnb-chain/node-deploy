#!/usr/bin/env bash
bash +x ./setup_bc_node.sh native_stop 
bash +x ./setup_bsc_node.sh native_stop
bash +x ./setup_bsc_relayer.sh native_stop
bash +x ./setup_oracle_relayer.sh native_stop

