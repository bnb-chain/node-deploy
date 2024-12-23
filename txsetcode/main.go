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
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/params"
	"github.com/holiman/uint256"
)

var edpoint = "http://127.0.0.1:8546"
var chainId = big.NewInt(714)

var account, _ = fromHexKey("59ba8068eb256d520179e903f43dacf6d8d57d72bd306e1bd603fdb8c8da10e8")
var key1, _ = crypto.HexToECDSA("b71c71a67e1177ad4e901695e1b4b9ee17ae16c6668d313eac2f96dbcda3f291")
var toAddr = common.HexToAddress("0x04d63aBCd2b9b1baa327f2Dda0f873F197ccd186")
var aa = common.HexToAddress("0x000000000000000000000000000000000000aaaa")

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
			hash, err := sendEther(c, account, toAddr, big.NewInt(1), nonce)
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

func sendEther(client *ethclient.Client, fromEO ExtAcc, toAddr common.Address, value *big.Int, nonce uint64) (common.Hash, error) {
	gasLimit := uint64(3e5)
	gasPrice := big.NewInt(params.GWei * 10)
	signer := types.NewPragueSigner(chainId)

	// will fail to apply, ignore
	auth1, _ := types.SignAuth(types.Authorization{
		ChainID: chainId.Uint64(),
		Address: aa,
		Nonce:   0,
	}, key1)

	txdata := &types.SetCodeTx{
		ChainID:   chainId.Uint64(),
		Nonce:     nonce,
		To:        toAddr,
		Gas:       gasLimit,
		GasFeeCap: uint256.MustFromBig(gasPrice),
		GasTipCap: uint256.MustFromBig(gasPrice),
		AuthList:  []types.Authorization{auth1},
	}
	signedTx := types.MustSignNewTx(fromEO.Key, signer, txdata)
	err := client.SendTransaction(context.Background(), signedTx)
	if err != nil {
		return common.Hash{}, err
	}
	txhash := signedTx.Hash()
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
