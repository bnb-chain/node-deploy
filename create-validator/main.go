package main

import (
	"bytes"
	"context"
	"flag"
	"fmt"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/accounts"
	"github.com/ethereum/go-ethereum/accounts/keystore"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	validatorpb "github.com/prysmaticlabs/prysm/v5/proto/prysm/v1alpha1/validator-client"
	"github.com/prysmaticlabs/prysm/v5/validator/accounts/iface"
	"github.com/prysmaticlabs/prysm/v5/validator/accounts/wallet"
	"github.com/prysmaticlabs/prysm/v5/validator/keymanager"

	"create-validator/abi"
)

var (
	valDescription  = flag.String("validator-desc", "test-val", "validator description")
	amount          = flag.Int("amount", 2001, "amount of BNB to delegate")
	rpcUrl          = flag.String("rpc-url", "http://127.0.0.1:8545", "rpc url")
	consensusKeyDir = flag.String("consensus-key-dir", "", "consensus keys dir")
	voteKeyDir      = flag.String("vote-key-dir", "", "vote keys dir")
	passwordPath    = flag.String("password-path", "", "password dir")
)

func main() {
	flag.Parse()

	if *consensusKeyDir == "" {
		panic("consensus-keys-dir is required")
	}
	if *voteKeyDir == "" {
		panic("vote-keys-dir is required")
	}
	if *passwordPath == "" {
		panic("password-path is required")
	}

	client, err := ethclient.Dial(*rpcUrl)
	if err != nil {
		panic(err)
	}

	bz, err := os.ReadFile(*passwordPath)
	if err != nil {
		panic(err)
	}
	password := string(bytes.TrimSpace(bz))

	consensusKs := keystore.NewKeyStore(*consensusKeyDir+"/keystore", keystore.StandardScryptN, keystore.StandardScryptP)
	consensusAddr := consensusKs.Accounts()[0].Address
	consensusAcc := accounts.Account{Address: consensusAddr}
	err = consensusKs.Unlock(consensusAcc, password)
	if err != nil {
		panic(err)
	}

	voteKm, err := getBlsKeymanager(*voteKeyDir+"/bls/wallet", password)
	if err != nil {
		panic(err)
	}

	pubkeys, err := voteKm.FetchValidatingPublicKeys(context.Background())
	if err != nil {
		panic(err)
	}
	pubKey := pubkeys[0]

	delegation := new(big.Int).Mul(big.NewInt(int64(*amount)), big.NewInt(1e18)) // 5000000 BNB
	description := abi.StakeHubDescription{
		Moniker:  *valDescription,
		Identity: *valDescription,
		Website:  *valDescription,
		Details:  *valDescription,
	}
	commission := abi.StakeHubCommission{
		Rate:          100,
		MaxRate:       1000,
		MaxChangeRate: 100,
	}

	chainId, err := client.ChainID(context.Background())
	if err != nil {
		panic(err)
	}
	paddedChainIdBytes := make([]byte, 32)
	copy(paddedChainIdBytes[32-len(chainId.Bytes()):], chainId.Bytes())

	msgHash := crypto.Keccak256(append(consensusAddr.Bytes(), append(pubKey[:], paddedChainIdBytes...)...))
	req := validatorpb.SignRequest{
		PublicKey:   pubKey[:],
		SigningRoot: msgHash,
	}
	proof, err := voteKm.Sign(context.Background(), &req)
	if err != nil {
		panic(err)
	}

	stakeHubAbi, err := abi.StakeHubMetaData.GetAbi()
	if err != nil {
		panic(err)
	}
	method := "createValidator"
	data, err := stakeHubAbi.Pack(method, consensusAddr, pubKey[:], proof.Marshal(), commission, description)
	if err != nil {
		panic(err)
	}

	nonce, err := client.PendingNonceAt(context.Background(), consensusAddr)
	if err != nil {
		panic(err)
	}
	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		panic(err)
	}
	stakeHubAddr := common.HexToAddress("0x0000000000000000000000000000000000002002")
	tx := types.NewTx(&types.LegacyTx{
		Nonce:    nonce,
		To:       &stakeHubAddr,
		Value:    delegation,
		Gas:      2000000,
		GasPrice: gasPrice,
		Data:     data,
	})

	signedTx, err := consensusKs.SignTx(consensusAcc, tx, chainId)
	if err != nil {
		panic(err)
	}

	err = client.SendTransaction(context.Background(), signedTx)
	if err != nil {
		panic(err)
	}

	fmt.Println("send createValidator. Tx hash:", signedTx.Hash().Hex())
}

func getBlsKeymanager(walletPath, password string) (keymanager.IKeymanager, error) {
	w, err := wallet.OpenWallet(context.Background(), &wallet.Config{
		WalletDir:      walletPath,
		WalletPassword: password,
	})
	if err != nil {
		panic(err)
	}

	km, err := w.InitializeKeymanager(context.Background(), iface.InitKeymanagerConfig{ListenForChanges: false})
	if err != nil {
		panic(err)
	}

	return km, nil
}
