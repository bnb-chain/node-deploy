package main

import (
	"context"
	"crypto/ecdsa"
	"crypto/rand"
	"errors"
	"flag"
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

	"github.com/consensys/gnark-crypto/ecc/bls12-381/fr"
	gokzg4844 "github.com/crate-crypto/go-kzg-4844"
)

// todo do the same for sending blob transaction

var (
	account, _   = fromHexKey("59ba8068eb256d520179e903f43dacf6d8d57d72bd306e1bd603fdb8c8da10e8")
	toAddr       = common.HexToAddress("0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186")
	endpointFlag = flag.String("endpoint", "http://127.0.0.1:8545", "The endpoint of the chain")
	chainIdFlag  = flag.Int64("chainId", 714, "The chainId of the chain")
	chainId      *big.Int
)
var (
	emptyBlob          = kzg4844.Blob{}
	emptyBlobCommit, _ = kzg4844.BlobToCommitment(emptyBlob)
	emptyBlobProof, _  = kzg4844.ComputeBlobProof(emptyBlob, emptyBlobCommit)
)

func main() {
	flag.Parse()
	chainId = big.NewInt(*chainIdFlag)
	c, _ := ethclient.Dial(*endpointFlag)
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
	tx := createNonEmptyBlobTxs(fromEO.Key, withSidecar, toAddr, value, nonce)

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

func createNonEmptyBlobTxs(key *ecdsa.PrivateKey, withSidecar bool, toAddr common.Address, value *uint256.Int, nonce uint64) *types.Transaction {
	blob := randBlob()

	commitment, err := kzg4844.BlobToCommitment(blob)
	if err != nil {
		fmt.Println("error2: ", err)
	}
	proof, err := kzg4844.ComputeBlobProof(blob, commitment)
	if err != nil {
		fmt.Println("error3: ", err)
	}

	sidecar := &types.BlobTxSidecar{
		Blobs:       []kzg4844.Blob{blob},
		Commitments: []kzg4844.Commitment{commitment},
		Proofs:      []kzg4844.Proof{proof},
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

func randBlob() kzg4844.Blob {
	var blob kzg4844.Blob
	for i := 0; i < len(blob); i += gokzg4844.SerializedScalarSize {
		fieldElementBytes := randFieldElement()
		copy(blob[i:i+gokzg4844.SerializedScalarSize], fieldElementBytes[:])
	}
	return blob
}

func randFieldElement() [32]byte {
	bytes := make([]byte, 32)
	_, err := rand.Read(bytes)
	if err != nil {
		panic("failed to get random field element")
	}
	var r fr.Element
	r.SetBytes(bytes)

	return gokzg4844.SerializeScalar(r)
}
