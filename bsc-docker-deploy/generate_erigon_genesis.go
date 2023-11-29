package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
)

var defaultBscGenesisPath = "./bsc-genesis-contract/genesis.json"
var defaultErigonGenesisPath = "./bsc-genesis-contract/erigon-genesis.json"

var (
	bscGenesisPath    *string
	erigonGenesisPath *string
)

func main() {
	// Define the flags
	bscGenesisPath = flag.String("bscGenesisPath", defaultBscGenesisPath, "Path to BSC Genesis file")
	erigonGenesisPath = flag.String("erigonGenesisPath", defaultErigonGenesisPath, "Path to write the Erigon Genesis file")

	flag.Usage = func() {
		fmt.Println("Usage: go run main.go [options]")
		fmt.Println("[options]:")
		flag.PrintDefaults()
	}

	// Parse the flags
	flag.Parse()
	fmt.Printf("Reading BSC genesis from %s ...\n", *bscGenesisPath)
	file, err := os.Open(*bscGenesisPath)
	if err != nil {
		panic(fmt.Errorf("failed to open BSC genesis at path: %s, check if the file exists", *bscGenesisPath))
	}
	defer file.Close()
	fileBytes, err := io.ReadAll(file)
	if err != nil {
		panic(err)
	}

	var jsonMap map[string]interface{}
	json.Unmarshal(fileBytes, &jsonMap)
	// Adapt jsonMap to erigon genesis structure
	var configMap map[string]interface{} = jsonMap["config"].(map[string]interface{})
	configMap["ChainID"] = configMap["chainId"]
	delete(configMap, "chainId")
	configMap["ChainName"] = "devnet"
	configMap["Consensus"] = "parlia"

	// write modified genesis to new file
	erigonGenesisFile, err := os.Create(*erigonGenesisPath)
	if err != nil {
		panic(fmt.Errorf("failed to create erigon genesis file at path: %s", *erigonGenesisPath))
	}
	defer erigonGenesisFile.Close()
	erigonGenesisBytes, err := json.MarshalIndent(jsonMap, "", " ")
	if err != nil {
		panic(err)
	}
	_, err = erigonGenesisFile.Write(erigonGenesisBytes)
	if err != nil {
		panic(err)
	}
	fmt.Printf("Successfully wrote erigon genesis to %s\n", *erigonGenesisPath)
}
