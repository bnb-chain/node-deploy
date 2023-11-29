# bsc-docker-deploy

Deploy a local cluster of BSC validators using Docker.

## Steps to run

- If the `keys/` directory is empty , run the following command to generate a new set of keys for the validators:
    ```bash
    bash setup_keys.sh generate
    ```

    You can view the generated keys with:
    
    ```bash
    bash setup_keys.sh view
    ```
    
        


- Initialize the BSC, Beacon Chain, and bsc-genesis-contract repositories:
    ```bash
    bash init_submodules.sh
    ```

- Build these repositories:
    ```bash
    bash build_submodules.sh

    ```
    To try new features you can checkout different branches of these repositories and rebuild.


- Generate `genesis.json`:
    ```bash
    bash generate_genesis.sh
    ```

  This will generate the genesis file with all 5 authorities as validators. If you want a custom number of validators (up to 5) you can pass the number as an argument. E.g.

     ```bash
    bash generate_genesis.sh 3
    ```
    This will register 3 validators: Alice , Bob and Charlie.

- Build the docker image:
    ```bash
    bash docker_build.sh
    ```

- Run the cluster:
   ```bash
   docker-compose up
   ```

    This will run all 5 validators.  

    If you want to run certain validators (e.g. Alice, Charlie and Eve) you can pass the names as arguments to docker compose:

    ```bash
    docker-compose up alice charlie eve
    ```

## (Optional) Run Erigon node
You may also choose to run an Erigon node to sync up with the validators in the cluster.

The steps to do so are the following:

1. Having already generated the BSC `genesis.json`, run the following command to convert this genesis to Erigon format:
   
   ```bash
   go run generate_erigon_genesis.go
   ```
    This will automatically read the BSC `genesis.json` from `bsc-genesis-contract` and produce `erigon-genesis.json` in `bsc-genesis-contract`.  

    **Optional**: You can read the BSC genesis from a different filepath and write the Erigon genesis to a different filepath by utilizing the flags `-bscGenesisPath` and `-erigonGenesisPath` to override the default paths.

2. Build the Erigon docker image

    ```bash
    bash docker_build_erigon.sh
    ```

3. Run the Erigon node with `docker-compose`

    ```bash
    docker-compose up erigon alice bob charlie
    ```

    This will spin up a new network the 3 validators and 1 erigon node syncing to those validators.


