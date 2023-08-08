package main

import (
	"bytes"
	"encoding/binary"
	"encoding/hex"
	"flag"
	"fmt"

	"github.com/binance-chain/go-sdk/client/rpc"
	btypes "github.com/binance-chain/go-sdk/common/types"
	"github.com/ethereum/go-ethereum/common"
	"github.com/tendermint/tendermint/crypto/ed25519"
	"github.com/tendermint/tendermint/types"
)

var (
	bech32Addr  = flag.String("addr", "", "Bech32 format address")
	power       = flag.Int("power", 0, "voting power")
	provider    = flag.String("rpc", "", "node URL of beacon chain")
	height      = flag.Int64("height", 1, "height of query status from beacon chain")
	networkType = flag.Int("network-type", 0, "network type of beacon chain")
)

const (
	chainIDLength              uint64 = 32
	heightLength               uint64 = 8
	validatorSetHashLength     uint64 = 32
	validatorPubkeyLength      uint64 = 32
	validatorVotingPowerLength uint64 = 8
	appHashLength              uint64 = 32
	storeNameLengthBytesLength uint64 = 32
	keyLengthBytesLength       uint64 = 32
	valueLengthBytesLength     uint64 = 32
	maxConsensusStateLength    uint64 = 32 * (128 - 1) // maximum validator quantity 99
)

type ConsensusState struct {
	ChainID             string
	Height              uint64
	AppHash             []byte
	CurValidatorSetHash []byte
	NextValidatorSet    *types.ValidatorSet
}

// output:
// | chainID   | height   | appHash  | curValidatorSetHash | [{validator pubkey, voting power}] |
// | 32 bytes  | 8 bytes  | 32 bytes | 32 bytes            | [{32 bytes, 8 bytes}]              |
func (cs ConsensusState) EncodeConsensusState() ([]byte, error) {
	validatorSetLength := uint64(len(cs.NextValidatorSet.Validators))
	serializeLength := chainIDLength + heightLength + appHashLength + validatorSetHashLength + validatorSetLength*(validatorPubkeyLength+validatorVotingPowerLength)
	if serializeLength > maxConsensusStateLength {
		return nil, fmt.Errorf("too many validators %d, consensus state bytes should not exceed %d", len(cs.NextValidatorSet.Validators), maxConsensusStateLength)
	}

	encodingBytes := make([]byte, serializeLength)

	pos := uint64(0)
	if uint64(len(cs.ChainID)) > chainIDLength {
		return nil, fmt.Errorf("chainID length should be no more than 32")
	}
	copy(encodingBytes[pos:pos+chainIDLength], cs.ChainID)
	pos += chainIDLength

	binary.BigEndian.PutUint64(encodingBytes[pos:pos+heightLength], cs.Height)
	pos += heightLength

	copy(encodingBytes[pos:pos+appHashLength], cs.AppHash)
	pos += appHashLength

	copy(encodingBytes[pos:pos+validatorSetHashLength], cs.CurValidatorSetHash)
	pos += validatorSetHashLength

	for index := uint64(0); index < validatorSetLength; index++ {
		validator := cs.NextValidatorSet.Validators[index]
		pubkey, ok := validator.PubKey.(ed25519.PubKeyEd25519)
		if !ok {
			return nil, fmt.Errorf("invalid pubkey type")
		}

		copy(encodingBytes[pos:pos+validatorPubkeyLength], pubkey[:])
		pos += validatorPubkeyLength

		binary.BigEndian.PutUint64(encodingBytes[pos:pos+validatorVotingPowerLength], uint64(validator.VotingPower))
		pos += validatorVotingPowerLength
	}

	return encodingBytes, nil
}

func main() {
	flag.Parse()

	if *bech32Addr != "" {
		Bech32PrefixAccAddr := "tbnb"
		if *networkType == 1 {
			Bech32PrefixAccAddr = "bnb"
		}
		bz, err := btypes.GetFromBech32(*bech32Addr, Bech32PrefixAccAddr)
		if err != nil {
			fmt.Println(err)
		}
		addr := btypes.AccAddress(bz)
		fmt.Println(common.BytesToAddress(addr.Bytes()))
	}

	if *power > 0 {
		fmt.Printf("0x%016x\n", *power)
	}

	if *provider != "" && *height > 0 {
		// get init consensus state
		rpcClient := rpc.NewRPCClient(*provider, btypes.ChainNetwork(*networkType))
		validators, err := rpcClient.Validators(height)
		if err != nil {
			fmt.Println(err)
			return
		}
		block, err := rpcClient.Block(height)
		if err != nil {
			fmt.Println(err)
			return
		}

		var proposer *types.Validator
		for _, validator := range validators.Validators {
			if bytes.Equal(validator.Address, block.Block.ProposerAddress) {
				proposer = validator
				break
			}
		}

		cs := ConsensusState{
			ChainID:             block.Block.ChainID,
			Height:              uint64(block.Block.Height),
			AppHash:             block.Block.AppHash,
			CurValidatorSetHash: block.Block.ValidatorsHash,
			NextValidatorSet: &types.ValidatorSet{
				Validators: validators.Validators,
				Proposer:   proposer,
			},
		}

		csBytes, err := cs.EncodeConsensusState()
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(hex.EncodeToString(csBytes))
	}
}
