package main

import (
	"context"
	"crypto/ecdsa"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/crypto/kzg4844"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/params"
	"github.com/holiman/uint256"
)

// todo do the same for sending blob transaction

var edpoint = "http://127.0.0.1:8545"
var chainId = big.NewInt(714)

var account, _ = fromHexKey("59ba8068eb256d520179e903f43dacf6d8d57d72bd306e1bd603fdb8c8da10e8")
var toAddr = common.HexToAddress("0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186")

var (
	emptyBlob          = kzg4844.Blob{}
	emptyBlobCommit, _ = kzg4844.BlobToCommitment(emptyBlob)
	emptyBlobProof, _  = kzg4844.ComputeBlobProof(emptyBlob, emptyBlobCommit)
)

func main() {
	c, _ := ethclient.Dial(edpoint)
	t := time.NewTicker(200 * time.Millisecond)
	for {
		select {
		case <-t.C:
			nonce, err := c.PendingNonceAt(context.Background(), account.addr)
			if err != nil {
				fmt.Println(err)
				continue
			}
			hash, err := sendBlobs(c, account, toAddr, uint256.NewInt(1), nonce, true)
			if err != nil {
				fmt.Println(err)
				continue
			}
			fmt.Printf("send tx hash %s \n", hash)
		}
	}
}

type ExtAcc struct {
	Key  *ecdsa.PrivateKey
	addr common.Address
}

func sendBlobs(client *ethclient.Client, fromEO ExtAcc, toAddr common.Address, value *uint256.Int, nonce uint64, withSidecar bool) (common.Hash, error) {
	tx := createEmptyBlobTx(fromEO.Key, withSidecar, toAddr, value, nonce)

	err := client.SendTransaction(context.Background(), tx)
	if err != nil {
		return common.Hash{}, err
	}
	txhash := tx.Hash()
	return txhash, nil
}

func fromHexKey(hexkey string) (ExtAcc, error) {
	key, err := crypto.HexToECDSA(hexkey)
	if err != nil {
		return ExtAcc{}, err
	}
	pubKey := key.Public()
	pubKeyECDSA, ok := pubKey.(*ecdsa.PublicKey)
	if !ok {
		err = errors.New("publicKey is not of type *ecdsa.PublicKey")
		return ExtAcc{}, err
	}
	addr := crypto.PubkeyToAddress(*pubKeyECDSA)
	return ExtAcc{key, addr}, nil
}

func createEmptyBlobTx(key *ecdsa.PrivateKey, withSidecar bool, toAddr common.Address, value *uint256.Int, nonce uint64) *types.Transaction {
	sidecar := &types.BlobTxSidecar{
		Blobs:       []kzg4844.Blob{emptyBlob},
		Commitments: []kzg4844.Commitment{emptyBlobCommit},
		Proofs:      []kzg4844.Proof{emptyBlobProof},
	}
	blobtx := &types.BlobTx{
		ChainID:    uint256.NewInt(714),
		Nonce:      nonce,
		GasTipCap:  uint256.NewInt(10 * params.GWei),
		GasFeeCap:  uint256.NewInt(10 * params.GWei),
		Gas:        25000,
		To:         toAddr,
		Value:      value,
		Data:       nil,
		BlobFeeCap: uint256.NewInt(3 * params.GWei),
		BlobHashes: sidecar.BlobHashes(),
	}
	if withSidecar {
		blobtx.Sidecar = sidecar
	}
	signer := types.NewCancunSigner(blobtx.ChainID.ToBig())
	return types.MustSignNewTx(key, signer, blobtx)
}
