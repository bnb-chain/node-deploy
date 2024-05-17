// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package abi

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// StakeHubCommission is an auto generated low-level Go binding around an user-defined struct.
type StakeHubCommission struct {
	Rate          uint64
	MaxRate       uint64
	MaxChangeRate uint64
}

// StakeHubDescription is an auto generated low-level Go binding around an user-defined struct.
type StakeHubDescription struct {
	Moniker  string
	Identity string
	Website  string
	Details  string
}

// StakeHubMetaData contains all meta data concerning the StakeHub contract.
var StakeHubMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"receive\",\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"BREATHE_BLOCK_INTERVAL\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"DEAD_ADDRESS\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"LOCK_AMOUNT\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"REDELEGATE_FEE_RATE_BASE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"addToBlackList\",\"inputs\":[{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"assetProtector\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"blackList\",\"inputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"claim\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"requestNumber\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"claimBatch\",\"inputs\":[{\"name\":\"operatorAddresses\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"requestNumbers\",\"type\":\"uint256[]\",\"internalType\":\"uint256[]\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"consensusExpiration\",\"inputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"consensusToOperator\",\"inputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"createValidator\",\"inputs\":[{\"name\":\"consensusAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"voteAddress\",\"type\":\"bytes\",\"internalType\":\"bytes\"},{\"name\":\"blsProof\",\"type\":\"bytes\",\"internalType\":\"bytes\"},{\"name\":\"commission\",\"type\":\"tuple\",\"internalType\":\"structStakeHub.Commission\",\"components\":[{\"name\":\"rate\",\"type\":\"uint64\",\"internalType\":\"uint64\"},{\"name\":\"maxRate\",\"type\":\"uint64\",\"internalType\":\"uint64\"},{\"name\":\"maxChangeRate\",\"type\":\"uint64\",\"internalType\":\"uint64\"}]},{\"name\":\"description\",\"type\":\"tuple\",\"internalType\":\"structStakeHub.Description\",\"components\":[{\"name\":\"moniker\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"identity\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"website\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"details\",\"type\":\"string\",\"internalType\":\"string\"}]}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"delegate\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"delegateVotePower\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"distributeReward\",\"inputs\":[{\"name\":\"consensusAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"doubleSignSlash\",\"inputs\":[{\"name\":\"consensusAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"downtimeJailTime\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"downtimeSlash\",\"inputs\":[{\"name\":\"consensusAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"downtimeSlashAmount\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"editCommissionRate\",\"inputs\":[{\"name\":\"commissionRate\",\"type\":\"uint64\",\"internalType\":\"uint64\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"editConsensusAddress\",\"inputs\":[{\"name\":\"newConsensusAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"editDescription\",\"inputs\":[{\"name\":\"description\",\"type\":\"tuple\",\"internalType\":\"structStakeHub.Description\",\"components\":[{\"name\":\"moniker\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"identity\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"website\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"details\",\"type\":\"string\",\"internalType\":\"string\"}]}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"editVoteAddress\",\"inputs\":[{\"name\":\"newVoteAddress\",\"type\":\"bytes\",\"internalType\":\"bytes\"},{\"name\":\"blsProof\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"felonyJailTime\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"felonySlashAmount\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidatorBasicInfo\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"consensusAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"creditContract\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"createdTime\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"voteAddress\",\"type\":\"bytes\",\"internalType\":\"bytes\"},{\"name\":\"jailed\",\"type\":\"bool\",\"internalType\":\"bool\"},{\"name\":\"jailUntil\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidatorCommission\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"tuple\",\"internalType\":\"structStakeHub.Commission\",\"components\":[{\"name\":\"rate\",\"type\":\"uint64\",\"internalType\":\"uint64\"},{\"name\":\"maxRate\",\"type\":\"uint64\",\"internalType\":\"uint64\"},{\"name\":\"maxChangeRate\",\"type\":\"uint64\",\"internalType\":\"uint64\"}]}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidatorDescription\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"tuple\",\"internalType\":\"structStakeHub.Description\",\"components\":[{\"name\":\"moniker\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"identity\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"website\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"details\",\"type\":\"string\",\"internalType\":\"string\"}]}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidatorElectionInfo\",\"inputs\":[{\"name\":\"offset\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"limit\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"consensusAddrs\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"votingPowers\",\"type\":\"uint256[]\",\"internalType\":\"uint256[]\"},{\"name\":\"voteAddrs\",\"type\":\"bytes[]\",\"internalType\":\"bytes[]\"},{\"name\":\"totalLength\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidatorRewardRecord\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"index\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidatorTotalPooledBNBRecord\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"index\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getValidators\",\"inputs\":[{\"name\":\"offset\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"limit\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"operatorAddrs\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"creditAddrs\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"totalLength\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"initialize\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"isPaused\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"maliciousVoteSlash\",\"inputs\":[{\"name\":\"voteAddress\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"maxElectedValidators\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"maxFelonyBetweenBreatheBlock\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"minDelegationBNBChange\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"minSelfDelegationBNB\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"numOfJailed\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"pause\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"redelegate\",\"inputs\":[{\"name\":\"srcValidator\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"dstValidator\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"shares\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"delegateVotePower\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"redelegateFeeRate\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"removeFromBlackList\",\"inputs\":[{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"resume\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"syncGovToken\",\"inputs\":[{\"name\":\"operatorAddresses\",\"type\":\"address[]\",\"internalType\":\"address[]\"},{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"transferGasLimit\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"unbondPeriod\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"undelegate\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"shares\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"unjail\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"updateParam\",\"inputs\":[{\"name\":\"key\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"value\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"voteExpiration\",\"inputs\":[{\"name\":\"\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"voteToOperator\",\"inputs\":[{\"name\":\"\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"Claimed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"delegator\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"bnbAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"CommissionRateEdited\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"commissionRate\",\"type\":\"uint64\",\"indexed\":false,\"internalType\":\"uint64\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ConsensusAddressEdited\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"newConsensusAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Delegated\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"delegator\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"shares\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"bnbAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"DescriptionEdited\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Initialized\",\"inputs\":[{\"name\":\"version\",\"type\":\"uint8\",\"indexed\":false,\"internalType\":\"uint8\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ParamChange\",\"inputs\":[{\"name\":\"key\",\"type\":\"string\",\"indexed\":false,\"internalType\":\"string\"},{\"name\":\"value\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Paused\",\"inputs\":[],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Redelegated\",\"inputs\":[{\"name\":\"srcValidator\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"dstValidator\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"delegator\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"oldShares\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"newShares\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"bnbAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Resumed\",\"inputs\":[],\"anonymous\":false},{\"type\":\"event\",\"name\":\"RewardDistributeFailed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"failReason\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"RewardDistributed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"reward\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Undelegated\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"delegator\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"shares\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"bnbAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ValidatorCreated\",\"inputs\":[{\"name\":\"consensusAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"creditContract\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"voteAddress\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ValidatorEmptyJailed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ValidatorJailed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ValidatorSlashed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"jailUntil\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"slashAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"slashType\",\"type\":\"uint8\",\"indexed\":false,\"internalType\":\"enumStakeHub.SlashType\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ValidatorUnjailed\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"VoteAddressEdited\",\"inputs\":[{\"name\":\"operatorAddress\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"newVoteAddress\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"AlreadySlashed\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"ConsensusAddressExpired\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"DelegationAmountTooSmall\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"DuplicateConsensusAddress\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"DuplicateMoniker\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"DuplicateVoteAddress\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InBlackList\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidCommission\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidConsensusAddress\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidMoniker\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidRequest\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidValue\",\"inputs\":[{\"name\":\"key\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"value\",\"type\":\"bytes\",\"internalType\":\"bytes\"}]},{\"type\":\"error\",\"name\":\"InvalidVoteAddress\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"JailTimeNotExpired\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NoMoreFelonyAllowed\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"OnlyAssetProtector\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"OnlyCoinbase\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"OnlySelfDelegation\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"OnlySystemContract\",\"inputs\":[{\"name\":\"systemContract\",\"type\":\"address\",\"internalType\":\"address\"}]},{\"type\":\"error\",\"name\":\"OnlyZeroGasPrice\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"SameValidator\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"SelfDelegationNotEnough\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"StakeHubPaused\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"TransferFailed\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"UnknownParam\",\"inputs\":[{\"name\":\"key\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"value\",\"type\":\"bytes\",\"internalType\":\"bytes\"}]},{\"type\":\"error\",\"name\":\"UpdateTooFrequently\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"ValidatorExisted\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"ValidatorNotExist\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"ValidatorNotJailed\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"VoteAddressExpired\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"ZeroShares\",\"inputs\":[]}]",
}

// StakeHubABI is the input ABI used to generate the binding from.
// Deprecated: Use StakeHubMetaData.ABI instead.
var StakeHubABI = StakeHubMetaData.ABI

// StakeHub is an auto generated Go binding around an Ethereum contract.
type StakeHub struct {
	StakeHubCaller     // Read-only binding to the contract
	StakeHubTransactor // Write-only binding to the contract
	StakeHubFilterer   // Log filterer for contract events
}

// StakeHubCaller is an auto generated read-only Go binding around an Ethereum contract.
type StakeHubCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StakeHubTransactor is an auto generated write-only Go binding around an Ethereum contract.
type StakeHubTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StakeHubFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type StakeHubFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StakeHubSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type StakeHubSession struct {
	Contract     *StakeHub         // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// StakeHubCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type StakeHubCallerSession struct {
	Contract *StakeHubCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts   // Call options to use throughout this session
}

// StakeHubTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type StakeHubTransactorSession struct {
	Contract     *StakeHubTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts   // Transaction auth options to use throughout this session
}

// StakeHubRaw is an auto generated low-level Go binding around an Ethereum contract.
type StakeHubRaw struct {
	Contract *StakeHub // Generic contract binding to access the raw methods on
}

// StakeHubCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type StakeHubCallerRaw struct {
	Contract *StakeHubCaller // Generic read-only contract binding to access the raw methods on
}

// StakeHubTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type StakeHubTransactorRaw struct {
	Contract *StakeHubTransactor // Generic write-only contract binding to access the raw methods on
}

// NewStakeHub creates a new instance of StakeHub, bound to a specific deployed contract.
func NewStakeHub(address common.Address, backend bind.ContractBackend) (*StakeHub, error) {
	contract, err := bindStakeHub(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &StakeHub{StakeHubCaller: StakeHubCaller{contract: contract}, StakeHubTransactor: StakeHubTransactor{contract: contract}, StakeHubFilterer: StakeHubFilterer{contract: contract}}, nil
}

// NewStakeHubCaller creates a new read-only instance of StakeHub, bound to a specific deployed contract.
func NewStakeHubCaller(address common.Address, caller bind.ContractCaller) (*StakeHubCaller, error) {
	contract, err := bindStakeHub(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &StakeHubCaller{contract: contract}, nil
}

// NewStakeHubTransactor creates a new write-only instance of StakeHub, bound to a specific deployed contract.
func NewStakeHubTransactor(address common.Address, transactor bind.ContractTransactor) (*StakeHubTransactor, error) {
	contract, err := bindStakeHub(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &StakeHubTransactor{contract: contract}, nil
}

// NewStakeHubFilterer creates a new log filterer instance of StakeHub, bound to a specific deployed contract.
func NewStakeHubFilterer(address common.Address, filterer bind.ContractFilterer) (*StakeHubFilterer, error) {
	contract, err := bindStakeHub(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &StakeHubFilterer{contract: contract}, nil
}

// bindStakeHub binds a generic wrapper to an already deployed contract.
func bindStakeHub(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := StakeHubMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_StakeHub *StakeHubRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _StakeHub.Contract.StakeHubCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_StakeHub *StakeHubRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StakeHub.Contract.StakeHubTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_StakeHub *StakeHubRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _StakeHub.Contract.StakeHubTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_StakeHub *StakeHubCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _StakeHub.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_StakeHub *StakeHubTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StakeHub.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_StakeHub *StakeHubTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _StakeHub.Contract.contract.Transact(opts, method, params...)
}

// BREATHEBLOCKINTERVAL is a free data retrieval call binding the contract method 0x1fa8882b.
//
// Solidity: function BREATHE_BLOCK_INTERVAL() view returns(uint256)
func (_StakeHub *StakeHubCaller) BREATHEBLOCKINTERVAL(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "BREATHE_BLOCK_INTERVAL")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// BREATHEBLOCKINTERVAL is a free data retrieval call binding the contract method 0x1fa8882b.
//
// Solidity: function BREATHE_BLOCK_INTERVAL() view returns(uint256)
func (_StakeHub *StakeHubSession) BREATHEBLOCKINTERVAL() (*big.Int, error) {
	return _StakeHub.Contract.BREATHEBLOCKINTERVAL(&_StakeHub.CallOpts)
}

// BREATHEBLOCKINTERVAL is a free data retrieval call binding the contract method 0x1fa8882b.
//
// Solidity: function BREATHE_BLOCK_INTERVAL() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) BREATHEBLOCKINTERVAL() (*big.Int, error) {
	return _StakeHub.Contract.BREATHEBLOCKINTERVAL(&_StakeHub.CallOpts)
}

// DEADADDRESS is a free data retrieval call binding the contract method 0x4e6fd6c4.
//
// Solidity: function DEAD_ADDRESS() view returns(address)
func (_StakeHub *StakeHubCaller) DEADADDRESS(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "DEAD_ADDRESS")
	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err
}

// DEADADDRESS is a free data retrieval call binding the contract method 0x4e6fd6c4.
//
// Solidity: function DEAD_ADDRESS() view returns(address)
func (_StakeHub *StakeHubSession) DEADADDRESS() (common.Address, error) {
	return _StakeHub.Contract.DEADADDRESS(&_StakeHub.CallOpts)
}

// DEADADDRESS is a free data retrieval call binding the contract method 0x4e6fd6c4.
//
// Solidity: function DEAD_ADDRESS() view returns(address)
func (_StakeHub *StakeHubCallerSession) DEADADDRESS() (common.Address, error) {
	return _StakeHub.Contract.DEADADDRESS(&_StakeHub.CallOpts)
}

// LOCKAMOUNT is a free data retrieval call binding the contract method 0x8a4d3fa8.
//
// Solidity: function LOCK_AMOUNT() view returns(uint256)
func (_StakeHub *StakeHubCaller) LOCKAMOUNT(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "LOCK_AMOUNT")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// LOCKAMOUNT is a free data retrieval call binding the contract method 0x8a4d3fa8.
//
// Solidity: function LOCK_AMOUNT() view returns(uint256)
func (_StakeHub *StakeHubSession) LOCKAMOUNT() (*big.Int, error) {
	return _StakeHub.Contract.LOCKAMOUNT(&_StakeHub.CallOpts)
}

// LOCKAMOUNT is a free data retrieval call binding the contract method 0x8a4d3fa8.
//
// Solidity: function LOCK_AMOUNT() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) LOCKAMOUNT() (*big.Int, error) {
	return _StakeHub.Contract.LOCKAMOUNT(&_StakeHub.CallOpts)
}

// REDELEGATEFEERATEBASE is a free data retrieval call binding the contract method 0xd115a206.
//
// Solidity: function REDELEGATE_FEE_RATE_BASE() view returns(uint256)
func (_StakeHub *StakeHubCaller) REDELEGATEFEERATEBASE(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "REDELEGATE_FEE_RATE_BASE")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// REDELEGATEFEERATEBASE is a free data retrieval call binding the contract method 0xd115a206.
//
// Solidity: function REDELEGATE_FEE_RATE_BASE() view returns(uint256)
func (_StakeHub *StakeHubSession) REDELEGATEFEERATEBASE() (*big.Int, error) {
	return _StakeHub.Contract.REDELEGATEFEERATEBASE(&_StakeHub.CallOpts)
}

// REDELEGATEFEERATEBASE is a free data retrieval call binding the contract method 0xd115a206.
//
// Solidity: function REDELEGATE_FEE_RATE_BASE() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) REDELEGATEFEERATEBASE() (*big.Int, error) {
	return _StakeHub.Contract.REDELEGATEFEERATEBASE(&_StakeHub.CallOpts)
}

// AssetProtector is a free data retrieval call binding the contract method 0xde88700b.
//
// Solidity: function assetProtector() view returns(address)
func (_StakeHub *StakeHubCaller) AssetProtector(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "assetProtector")
	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err
}

// AssetProtector is a free data retrieval call binding the contract method 0xde88700b.
//
// Solidity: function assetProtector() view returns(address)
func (_StakeHub *StakeHubSession) AssetProtector() (common.Address, error) {
	return _StakeHub.Contract.AssetProtector(&_StakeHub.CallOpts)
}

// AssetProtector is a free data retrieval call binding the contract method 0xde88700b.
//
// Solidity: function assetProtector() view returns(address)
func (_StakeHub *StakeHubCallerSession) AssetProtector() (common.Address, error) {
	return _StakeHub.Contract.AssetProtector(&_StakeHub.CallOpts)
}

// BlackList is a free data retrieval call binding the contract method 0x4838d165.
//
// Solidity: function blackList(address ) view returns(bool)
func (_StakeHub *StakeHubCaller) BlackList(opts *bind.CallOpts, arg0 common.Address) (bool, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "blackList", arg0)
	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err
}

// BlackList is a free data retrieval call binding the contract method 0x4838d165.
//
// Solidity: function blackList(address ) view returns(bool)
func (_StakeHub *StakeHubSession) BlackList(arg0 common.Address) (bool, error) {
	return _StakeHub.Contract.BlackList(&_StakeHub.CallOpts, arg0)
}

// BlackList is a free data retrieval call binding the contract method 0x4838d165.
//
// Solidity: function blackList(address ) view returns(bool)
func (_StakeHub *StakeHubCallerSession) BlackList(arg0 common.Address) (bool, error) {
	return _StakeHub.Contract.BlackList(&_StakeHub.CallOpts, arg0)
}

// ConsensusExpiration is a free data retrieval call binding the contract method 0x663706d3.
//
// Solidity: function consensusExpiration(address ) view returns(uint256)
func (_StakeHub *StakeHubCaller) ConsensusExpiration(opts *bind.CallOpts, arg0 common.Address) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "consensusExpiration", arg0)
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// ConsensusExpiration is a free data retrieval call binding the contract method 0x663706d3.
//
// Solidity: function consensusExpiration(address ) view returns(uint256)
func (_StakeHub *StakeHubSession) ConsensusExpiration(arg0 common.Address) (*big.Int, error) {
	return _StakeHub.Contract.ConsensusExpiration(&_StakeHub.CallOpts, arg0)
}

// ConsensusExpiration is a free data retrieval call binding the contract method 0x663706d3.
//
// Solidity: function consensusExpiration(address ) view returns(uint256)
func (_StakeHub *StakeHubCallerSession) ConsensusExpiration(arg0 common.Address) (*big.Int, error) {
	return _StakeHub.Contract.ConsensusExpiration(&_StakeHub.CallOpts, arg0)
}

// ConsensusToOperator is a free data retrieval call binding the contract method 0x86d54506.
//
// Solidity: function consensusToOperator(address ) view returns(address)
func (_StakeHub *StakeHubCaller) ConsensusToOperator(opts *bind.CallOpts, arg0 common.Address) (common.Address, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "consensusToOperator", arg0)
	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err
}

// ConsensusToOperator is a free data retrieval call binding the contract method 0x86d54506.
//
// Solidity: function consensusToOperator(address ) view returns(address)
func (_StakeHub *StakeHubSession) ConsensusToOperator(arg0 common.Address) (common.Address, error) {
	return _StakeHub.Contract.ConsensusToOperator(&_StakeHub.CallOpts, arg0)
}

// ConsensusToOperator is a free data retrieval call binding the contract method 0x86d54506.
//
// Solidity: function consensusToOperator(address ) view returns(address)
func (_StakeHub *StakeHubCallerSession) ConsensusToOperator(arg0 common.Address) (common.Address, error) {
	return _StakeHub.Contract.ConsensusToOperator(&_StakeHub.CallOpts, arg0)
}

// DowntimeJailTime is a free data retrieval call binding the contract method 0x76e7d6d6.
//
// Solidity: function downtimeJailTime() view returns(uint256)
func (_StakeHub *StakeHubCaller) DowntimeJailTime(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "downtimeJailTime")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// DowntimeJailTime is a free data retrieval call binding the contract method 0x76e7d6d6.
//
// Solidity: function downtimeJailTime() view returns(uint256)
func (_StakeHub *StakeHubSession) DowntimeJailTime() (*big.Int, error) {
	return _StakeHub.Contract.DowntimeJailTime(&_StakeHub.CallOpts)
}

// DowntimeJailTime is a free data retrieval call binding the contract method 0x76e7d6d6.
//
// Solidity: function downtimeJailTime() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) DowntimeJailTime() (*big.Int, error) {
	return _StakeHub.Contract.DowntimeJailTime(&_StakeHub.CallOpts)
}

// DowntimeSlashAmount is a free data retrieval call binding the contract method 0xd8ca511f.
//
// Solidity: function downtimeSlashAmount() view returns(uint256)
func (_StakeHub *StakeHubCaller) DowntimeSlashAmount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "downtimeSlashAmount")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// DowntimeSlashAmount is a free data retrieval call binding the contract method 0xd8ca511f.
//
// Solidity: function downtimeSlashAmount() view returns(uint256)
func (_StakeHub *StakeHubSession) DowntimeSlashAmount() (*big.Int, error) {
	return _StakeHub.Contract.DowntimeSlashAmount(&_StakeHub.CallOpts)
}

// DowntimeSlashAmount is a free data retrieval call binding the contract method 0xd8ca511f.
//
// Solidity: function downtimeSlashAmount() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) DowntimeSlashAmount() (*big.Int, error) {
	return _StakeHub.Contract.DowntimeSlashAmount(&_StakeHub.CallOpts)
}

// FelonyJailTime is a free data retrieval call binding the contract method 0xf1f74d84.
//
// Solidity: function felonyJailTime() view returns(uint256)
func (_StakeHub *StakeHubCaller) FelonyJailTime(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "felonyJailTime")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// FelonyJailTime is a free data retrieval call binding the contract method 0xf1f74d84.
//
// Solidity: function felonyJailTime() view returns(uint256)
func (_StakeHub *StakeHubSession) FelonyJailTime() (*big.Int, error) {
	return _StakeHub.Contract.FelonyJailTime(&_StakeHub.CallOpts)
}

// FelonyJailTime is a free data retrieval call binding the contract method 0xf1f74d84.
//
// Solidity: function felonyJailTime() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) FelonyJailTime() (*big.Int, error) {
	return _StakeHub.Contract.FelonyJailTime(&_StakeHub.CallOpts)
}

// FelonySlashAmount is a free data retrieval call binding the contract method 0xbdceadf3.
//
// Solidity: function felonySlashAmount() view returns(uint256)
func (_StakeHub *StakeHubCaller) FelonySlashAmount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "felonySlashAmount")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// FelonySlashAmount is a free data retrieval call binding the contract method 0xbdceadf3.
//
// Solidity: function felonySlashAmount() view returns(uint256)
func (_StakeHub *StakeHubSession) FelonySlashAmount() (*big.Int, error) {
	return _StakeHub.Contract.FelonySlashAmount(&_StakeHub.CallOpts)
}

// FelonySlashAmount is a free data retrieval call binding the contract method 0xbdceadf3.
//
// Solidity: function felonySlashAmount() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) FelonySlashAmount() (*big.Int, error) {
	return _StakeHub.Contract.FelonySlashAmount(&_StakeHub.CallOpts)
}

// GetValidatorBasicInfo is a free data retrieval call binding the contract method 0xcbb04d9d.
//
// Solidity: function getValidatorBasicInfo(address operatorAddress) view returns(address consensusAddress, address creditContract, uint256 createdTime, bytes voteAddress, bool jailed, uint256 jailUntil)
func (_StakeHub *StakeHubCaller) GetValidatorBasicInfo(opts *bind.CallOpts, operatorAddress common.Address) (struct {
	ConsensusAddress common.Address
	CreditContract   common.Address
	CreatedTime      *big.Int
	VoteAddress      []byte
	Jailed           bool
	JailUntil        *big.Int
}, error,
) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidatorBasicInfo", operatorAddress)

	outstruct := new(struct {
		ConsensusAddress common.Address
		CreditContract   common.Address
		CreatedTime      *big.Int
		VoteAddress      []byte
		Jailed           bool
		JailUntil        *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.ConsensusAddress = *abi.ConvertType(out[0], new(common.Address)).(*common.Address)
	outstruct.CreditContract = *abi.ConvertType(out[1], new(common.Address)).(*common.Address)
	outstruct.CreatedTime = *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)
	outstruct.VoteAddress = *abi.ConvertType(out[3], new([]byte)).(*[]byte)
	outstruct.Jailed = *abi.ConvertType(out[4], new(bool)).(*bool)
	outstruct.JailUntil = *abi.ConvertType(out[5], new(*big.Int)).(**big.Int)

	return *outstruct, err
}

// GetValidatorBasicInfo is a free data retrieval call binding the contract method 0xcbb04d9d.
//
// Solidity: function getValidatorBasicInfo(address operatorAddress) view returns(address consensusAddress, address creditContract, uint256 createdTime, bytes voteAddress, bool jailed, uint256 jailUntil)
func (_StakeHub *StakeHubSession) GetValidatorBasicInfo(operatorAddress common.Address) (struct {
	ConsensusAddress common.Address
	CreditContract   common.Address
	CreatedTime      *big.Int
	VoteAddress      []byte
	Jailed           bool
	JailUntil        *big.Int
}, error,
) {
	return _StakeHub.Contract.GetValidatorBasicInfo(&_StakeHub.CallOpts, operatorAddress)
}

// GetValidatorBasicInfo is a free data retrieval call binding the contract method 0xcbb04d9d.
//
// Solidity: function getValidatorBasicInfo(address operatorAddress) view returns(address consensusAddress, address creditContract, uint256 createdTime, bytes voteAddress, bool jailed, uint256 jailUntil)
func (_StakeHub *StakeHubCallerSession) GetValidatorBasicInfo(operatorAddress common.Address) (struct {
	ConsensusAddress common.Address
	CreditContract   common.Address
	CreatedTime      *big.Int
	VoteAddress      []byte
	Jailed           bool
	JailUntil        *big.Int
}, error,
) {
	return _StakeHub.Contract.GetValidatorBasicInfo(&_StakeHub.CallOpts, operatorAddress)
}

// GetValidatorCommission is a free data retrieval call binding the contract method 0x6ec01b27.
//
// Solidity: function getValidatorCommission(address operatorAddress) view returns((uint64,uint64,uint64))
func (_StakeHub *StakeHubCaller) GetValidatorCommission(opts *bind.CallOpts, operatorAddress common.Address) (StakeHubCommission, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidatorCommission", operatorAddress)
	if err != nil {
		return *new(StakeHubCommission), err
	}

	out0 := *abi.ConvertType(out[0], new(StakeHubCommission)).(*StakeHubCommission)

	return out0, err
}

// GetValidatorCommission is a free data retrieval call binding the contract method 0x6ec01b27.
//
// Solidity: function getValidatorCommission(address operatorAddress) view returns((uint64,uint64,uint64))
func (_StakeHub *StakeHubSession) GetValidatorCommission(operatorAddress common.Address) (StakeHubCommission, error) {
	return _StakeHub.Contract.GetValidatorCommission(&_StakeHub.CallOpts, operatorAddress)
}

// GetValidatorCommission is a free data retrieval call binding the contract method 0x6ec01b27.
//
// Solidity: function getValidatorCommission(address operatorAddress) view returns((uint64,uint64,uint64))
func (_StakeHub *StakeHubCallerSession) GetValidatorCommission(operatorAddress common.Address) (StakeHubCommission, error) {
	return _StakeHub.Contract.GetValidatorCommission(&_StakeHub.CallOpts, operatorAddress)
}

// GetValidatorDescription is a free data retrieval call binding the contract method 0xa43569b3.
//
// Solidity: function getValidatorDescription(address operatorAddress) view returns((string,string,string,string))
func (_StakeHub *StakeHubCaller) GetValidatorDescription(opts *bind.CallOpts, operatorAddress common.Address) (StakeHubDescription, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidatorDescription", operatorAddress)
	if err != nil {
		return *new(StakeHubDescription), err
	}

	out0 := *abi.ConvertType(out[0], new(StakeHubDescription)).(*StakeHubDescription)

	return out0, err
}

// GetValidatorDescription is a free data retrieval call binding the contract method 0xa43569b3.
//
// Solidity: function getValidatorDescription(address operatorAddress) view returns((string,string,string,string))
func (_StakeHub *StakeHubSession) GetValidatorDescription(operatorAddress common.Address) (StakeHubDescription, error) {
	return _StakeHub.Contract.GetValidatorDescription(&_StakeHub.CallOpts, operatorAddress)
}

// GetValidatorDescription is a free data retrieval call binding the contract method 0xa43569b3.
//
// Solidity: function getValidatorDescription(address operatorAddress) view returns((string,string,string,string))
func (_StakeHub *StakeHubCallerSession) GetValidatorDescription(operatorAddress common.Address) (StakeHubDescription, error) {
	return _StakeHub.Contract.GetValidatorDescription(&_StakeHub.CallOpts, operatorAddress)
}

// GetValidatorElectionInfo is a free data retrieval call binding the contract method 0x63a036b5.
//
// Solidity: function getValidatorElectionInfo(uint256 offset, uint256 limit) view returns(address[] consensusAddrs, uint256[] votingPowers, bytes[] voteAddrs, uint256 totalLength)
func (_StakeHub *StakeHubCaller) GetValidatorElectionInfo(opts *bind.CallOpts, offset *big.Int, limit *big.Int) (struct {
	ConsensusAddrs []common.Address
	VotingPowers   []*big.Int
	VoteAddrs      [][]byte
	TotalLength    *big.Int
}, error,
) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidatorElectionInfo", offset, limit)

	outstruct := new(struct {
		ConsensusAddrs []common.Address
		VotingPowers   []*big.Int
		VoteAddrs      [][]byte
		TotalLength    *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.ConsensusAddrs = *abi.ConvertType(out[0], new([]common.Address)).(*[]common.Address)
	outstruct.VotingPowers = *abi.ConvertType(out[1], new([]*big.Int)).(*[]*big.Int)
	outstruct.VoteAddrs = *abi.ConvertType(out[2], new([][]byte)).(*[][]byte)
	outstruct.TotalLength = *abi.ConvertType(out[3], new(*big.Int)).(**big.Int)

	return *outstruct, err
}

// GetValidatorElectionInfo is a free data retrieval call binding the contract method 0x63a036b5.
//
// Solidity: function getValidatorElectionInfo(uint256 offset, uint256 limit) view returns(address[] consensusAddrs, uint256[] votingPowers, bytes[] voteAddrs, uint256 totalLength)
func (_StakeHub *StakeHubSession) GetValidatorElectionInfo(offset *big.Int, limit *big.Int) (struct {
	ConsensusAddrs []common.Address
	VotingPowers   []*big.Int
	VoteAddrs      [][]byte
	TotalLength    *big.Int
}, error,
) {
	return _StakeHub.Contract.GetValidatorElectionInfo(&_StakeHub.CallOpts, offset, limit)
}

// GetValidatorElectionInfo is a free data retrieval call binding the contract method 0x63a036b5.
//
// Solidity: function getValidatorElectionInfo(uint256 offset, uint256 limit) view returns(address[] consensusAddrs, uint256[] votingPowers, bytes[] voteAddrs, uint256 totalLength)
func (_StakeHub *StakeHubCallerSession) GetValidatorElectionInfo(offset *big.Int, limit *big.Int) (struct {
	ConsensusAddrs []common.Address
	VotingPowers   []*big.Int
	VoteAddrs      [][]byte
	TotalLength    *big.Int
}, error,
) {
	return _StakeHub.Contract.GetValidatorElectionInfo(&_StakeHub.CallOpts, offset, limit)
}

// GetValidatorRewardRecord is a free data retrieval call binding the contract method 0xf80a3402.
//
// Solidity: function getValidatorRewardRecord(address operatorAddress, uint256 index) view returns(uint256)
func (_StakeHub *StakeHubCaller) GetValidatorRewardRecord(opts *bind.CallOpts, operatorAddress common.Address, index *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidatorRewardRecord", operatorAddress, index)
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// GetValidatorRewardRecord is a free data retrieval call binding the contract method 0xf80a3402.
//
// Solidity: function getValidatorRewardRecord(address operatorAddress, uint256 index) view returns(uint256)
func (_StakeHub *StakeHubSession) GetValidatorRewardRecord(operatorAddress common.Address, index *big.Int) (*big.Int, error) {
	return _StakeHub.Contract.GetValidatorRewardRecord(&_StakeHub.CallOpts, operatorAddress, index)
}

// GetValidatorRewardRecord is a free data retrieval call binding the contract method 0xf80a3402.
//
// Solidity: function getValidatorRewardRecord(address operatorAddress, uint256 index) view returns(uint256)
func (_StakeHub *StakeHubCallerSession) GetValidatorRewardRecord(operatorAddress common.Address, index *big.Int) (*big.Int, error) {
	return _StakeHub.Contract.GetValidatorRewardRecord(&_StakeHub.CallOpts, operatorAddress, index)
}

// GetValidatorTotalPooledBNBRecord is a free data retrieval call binding the contract method 0x8cd22b22.
//
// Solidity: function getValidatorTotalPooledBNBRecord(address operatorAddress, uint256 index) view returns(uint256)
func (_StakeHub *StakeHubCaller) GetValidatorTotalPooledBNBRecord(opts *bind.CallOpts, operatorAddress common.Address, index *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidatorTotalPooledBNBRecord", operatorAddress, index)
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// GetValidatorTotalPooledBNBRecord is a free data retrieval call binding the contract method 0x8cd22b22.
//
// Solidity: function getValidatorTotalPooledBNBRecord(address operatorAddress, uint256 index) view returns(uint256)
func (_StakeHub *StakeHubSession) GetValidatorTotalPooledBNBRecord(operatorAddress common.Address, index *big.Int) (*big.Int, error) {
	return _StakeHub.Contract.GetValidatorTotalPooledBNBRecord(&_StakeHub.CallOpts, operatorAddress, index)
}

// GetValidatorTotalPooledBNBRecord is a free data retrieval call binding the contract method 0x8cd22b22.
//
// Solidity: function getValidatorTotalPooledBNBRecord(address operatorAddress, uint256 index) view returns(uint256)
func (_StakeHub *StakeHubCallerSession) GetValidatorTotalPooledBNBRecord(operatorAddress common.Address, index *big.Int) (*big.Int, error) {
	return _StakeHub.Contract.GetValidatorTotalPooledBNBRecord(&_StakeHub.CallOpts, operatorAddress, index)
}

// GetValidators is a free data retrieval call binding the contract method 0xbff02e20.
//
// Solidity: function getValidators(uint256 offset, uint256 limit) view returns(address[] operatorAddrs, address[] creditAddrs, uint256 totalLength)
func (_StakeHub *StakeHubCaller) GetValidators(opts *bind.CallOpts, offset *big.Int, limit *big.Int) (struct {
	OperatorAddrs []common.Address
	CreditAddrs   []common.Address
	TotalLength   *big.Int
}, error,
) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "getValidators", offset, limit)

	outstruct := new(struct {
		OperatorAddrs []common.Address
		CreditAddrs   []common.Address
		TotalLength   *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.OperatorAddrs = *abi.ConvertType(out[0], new([]common.Address)).(*[]common.Address)
	outstruct.CreditAddrs = *abi.ConvertType(out[1], new([]common.Address)).(*[]common.Address)
	outstruct.TotalLength = *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)

	return *outstruct, err
}

// GetValidators is a free data retrieval call binding the contract method 0xbff02e20.
//
// Solidity: function getValidators(uint256 offset, uint256 limit) view returns(address[] operatorAddrs, address[] creditAddrs, uint256 totalLength)
func (_StakeHub *StakeHubSession) GetValidators(offset *big.Int, limit *big.Int) (struct {
	OperatorAddrs []common.Address
	CreditAddrs   []common.Address
	TotalLength   *big.Int
}, error,
) {
	return _StakeHub.Contract.GetValidators(&_StakeHub.CallOpts, offset, limit)
}

// GetValidators is a free data retrieval call binding the contract method 0xbff02e20.
//
// Solidity: function getValidators(uint256 offset, uint256 limit) view returns(address[] operatorAddrs, address[] creditAddrs, uint256 totalLength)
func (_StakeHub *StakeHubCallerSession) GetValidators(offset *big.Int, limit *big.Int) (struct {
	OperatorAddrs []common.Address
	CreditAddrs   []common.Address
	TotalLength   *big.Int
}, error,
) {
	return _StakeHub.Contract.GetValidators(&_StakeHub.CallOpts, offset, limit)
}

// IsPaused is a free data retrieval call binding the contract method 0xb187bd26.
//
// Solidity: function isPaused() view returns(bool)
func (_StakeHub *StakeHubCaller) IsPaused(opts *bind.CallOpts) (bool, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "isPaused")
	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err
}

// IsPaused is a free data retrieval call binding the contract method 0xb187bd26.
//
// Solidity: function isPaused() view returns(bool)
func (_StakeHub *StakeHubSession) IsPaused() (bool, error) {
	return _StakeHub.Contract.IsPaused(&_StakeHub.CallOpts)
}

// IsPaused is a free data retrieval call binding the contract method 0xb187bd26.
//
// Solidity: function isPaused() view returns(bool)
func (_StakeHub *StakeHubCallerSession) IsPaused() (bool, error) {
	return _StakeHub.Contract.IsPaused(&_StakeHub.CallOpts)
}

// MaxElectedValidators is a free data retrieval call binding the contract method 0xc473318f.
//
// Solidity: function maxElectedValidators() view returns(uint256)
func (_StakeHub *StakeHubCaller) MaxElectedValidators(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "maxElectedValidators")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// MaxElectedValidators is a free data retrieval call binding the contract method 0xc473318f.
//
// Solidity: function maxElectedValidators() view returns(uint256)
func (_StakeHub *StakeHubSession) MaxElectedValidators() (*big.Int, error) {
	return _StakeHub.Contract.MaxElectedValidators(&_StakeHub.CallOpts)
}

// MaxElectedValidators is a free data retrieval call binding the contract method 0xc473318f.
//
// Solidity: function maxElectedValidators() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) MaxElectedValidators() (*big.Int, error) {
	return _StakeHub.Contract.MaxElectedValidators(&_StakeHub.CallOpts)
}

// MaxFelonyBetweenBreatheBlock is a free data retrieval call binding the contract method 0xff69ab61.
//
// Solidity: function maxFelonyBetweenBreatheBlock() view returns(uint256)
func (_StakeHub *StakeHubCaller) MaxFelonyBetweenBreatheBlock(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "maxFelonyBetweenBreatheBlock")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// MaxFelonyBetweenBreatheBlock is a free data retrieval call binding the contract method 0xff69ab61.
//
// Solidity: function maxFelonyBetweenBreatheBlock() view returns(uint256)
func (_StakeHub *StakeHubSession) MaxFelonyBetweenBreatheBlock() (*big.Int, error) {
	return _StakeHub.Contract.MaxFelonyBetweenBreatheBlock(&_StakeHub.CallOpts)
}

// MaxFelonyBetweenBreatheBlock is a free data retrieval call binding the contract method 0xff69ab61.
//
// Solidity: function maxFelonyBetweenBreatheBlock() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) MaxFelonyBetweenBreatheBlock() (*big.Int, error) {
	return _StakeHub.Contract.MaxFelonyBetweenBreatheBlock(&_StakeHub.CallOpts)
}

// MinDelegationBNBChange is a free data retrieval call binding the contract method 0x38409988.
//
// Solidity: function minDelegationBNBChange() view returns(uint256)
func (_StakeHub *StakeHubCaller) MinDelegationBNBChange(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "minDelegationBNBChange")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// MinDelegationBNBChange is a free data retrieval call binding the contract method 0x38409988.
//
// Solidity: function minDelegationBNBChange() view returns(uint256)
func (_StakeHub *StakeHubSession) MinDelegationBNBChange() (*big.Int, error) {
	return _StakeHub.Contract.MinDelegationBNBChange(&_StakeHub.CallOpts)
}

// MinDelegationBNBChange is a free data retrieval call binding the contract method 0x38409988.
//
// Solidity: function minDelegationBNBChange() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) MinDelegationBNBChange() (*big.Int, error) {
	return _StakeHub.Contract.MinDelegationBNBChange(&_StakeHub.CallOpts)
}

// MinSelfDelegationBNB is a free data retrieval call binding the contract method 0x0661806e.
//
// Solidity: function minSelfDelegationBNB() view returns(uint256)
func (_StakeHub *StakeHubCaller) MinSelfDelegationBNB(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "minSelfDelegationBNB")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// MinSelfDelegationBNB is a free data retrieval call binding the contract method 0x0661806e.
//
// Solidity: function minSelfDelegationBNB() view returns(uint256)
func (_StakeHub *StakeHubSession) MinSelfDelegationBNB() (*big.Int, error) {
	return _StakeHub.Contract.MinSelfDelegationBNB(&_StakeHub.CallOpts)
}

// MinSelfDelegationBNB is a free data retrieval call binding the contract method 0x0661806e.
//
// Solidity: function minSelfDelegationBNB() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) MinSelfDelegationBNB() (*big.Int, error) {
	return _StakeHub.Contract.MinSelfDelegationBNB(&_StakeHub.CallOpts)
}

// NumOfJailed is a free data retrieval call binding the contract method 0xdaacdb66.
//
// Solidity: function numOfJailed() view returns(uint256)
func (_StakeHub *StakeHubCaller) NumOfJailed(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "numOfJailed")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// NumOfJailed is a free data retrieval call binding the contract method 0xdaacdb66.
//
// Solidity: function numOfJailed() view returns(uint256)
func (_StakeHub *StakeHubSession) NumOfJailed() (*big.Int, error) {
	return _StakeHub.Contract.NumOfJailed(&_StakeHub.CallOpts)
}

// NumOfJailed is a free data retrieval call binding the contract method 0xdaacdb66.
//
// Solidity: function numOfJailed() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) NumOfJailed() (*big.Int, error) {
	return _StakeHub.Contract.NumOfJailed(&_StakeHub.CallOpts)
}

// RedelegateFeeRate is a free data retrieval call binding the contract method 0xe992aaf5.
//
// Solidity: function redelegateFeeRate() view returns(uint256)
func (_StakeHub *StakeHubCaller) RedelegateFeeRate(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "redelegateFeeRate")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// RedelegateFeeRate is a free data retrieval call binding the contract method 0xe992aaf5.
//
// Solidity: function redelegateFeeRate() view returns(uint256)
func (_StakeHub *StakeHubSession) RedelegateFeeRate() (*big.Int, error) {
	return _StakeHub.Contract.RedelegateFeeRate(&_StakeHub.CallOpts)
}

// RedelegateFeeRate is a free data retrieval call binding the contract method 0xe992aaf5.
//
// Solidity: function redelegateFeeRate() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) RedelegateFeeRate() (*big.Int, error) {
	return _StakeHub.Contract.RedelegateFeeRate(&_StakeHub.CallOpts)
}

// TransferGasLimit is a free data retrieval call binding the contract method 0xe8f67c3b.
//
// Solidity: function transferGasLimit() view returns(uint256)
func (_StakeHub *StakeHubCaller) TransferGasLimit(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "transferGasLimit")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// TransferGasLimit is a free data retrieval call binding the contract method 0xe8f67c3b.
//
// Solidity: function transferGasLimit() view returns(uint256)
func (_StakeHub *StakeHubSession) TransferGasLimit() (*big.Int, error) {
	return _StakeHub.Contract.TransferGasLimit(&_StakeHub.CallOpts)
}

// TransferGasLimit is a free data retrieval call binding the contract method 0xe8f67c3b.
//
// Solidity: function transferGasLimit() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) TransferGasLimit() (*big.Int, error) {
	return _StakeHub.Contract.TransferGasLimit(&_StakeHub.CallOpts)
}

// UnbondPeriod is a free data retrieval call binding the contract method 0xfc0c5ff1.
//
// Solidity: function unbondPeriod() view returns(uint256)
func (_StakeHub *StakeHubCaller) UnbondPeriod(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "unbondPeriod")
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// UnbondPeriod is a free data retrieval call binding the contract method 0xfc0c5ff1.
//
// Solidity: function unbondPeriod() view returns(uint256)
func (_StakeHub *StakeHubSession) UnbondPeriod() (*big.Int, error) {
	return _StakeHub.Contract.UnbondPeriod(&_StakeHub.CallOpts)
}

// UnbondPeriod is a free data retrieval call binding the contract method 0xfc0c5ff1.
//
// Solidity: function unbondPeriod() view returns(uint256)
func (_StakeHub *StakeHubCallerSession) UnbondPeriod() (*big.Int, error) {
	return _StakeHub.Contract.UnbondPeriod(&_StakeHub.CallOpts)
}

// VoteExpiration is a free data retrieval call binding the contract method 0xefdbf0e1.
//
// Solidity: function voteExpiration(bytes ) view returns(uint256)
func (_StakeHub *StakeHubCaller) VoteExpiration(opts *bind.CallOpts, arg0 []byte) (*big.Int, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "voteExpiration", arg0)
	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err
}

// VoteExpiration is a free data retrieval call binding the contract method 0xefdbf0e1.
//
// Solidity: function voteExpiration(bytes ) view returns(uint256)
func (_StakeHub *StakeHubSession) VoteExpiration(arg0 []byte) (*big.Int, error) {
	return _StakeHub.Contract.VoteExpiration(&_StakeHub.CallOpts, arg0)
}

// VoteExpiration is a free data retrieval call binding the contract method 0xefdbf0e1.
//
// Solidity: function voteExpiration(bytes ) view returns(uint256)
func (_StakeHub *StakeHubCallerSession) VoteExpiration(arg0 []byte) (*big.Int, error) {
	return _StakeHub.Contract.VoteExpiration(&_StakeHub.CallOpts, arg0)
}

// VoteToOperator is a free data retrieval call binding the contract method 0x17b4f353.
//
// Solidity: function voteToOperator(bytes ) view returns(address)
func (_StakeHub *StakeHubCaller) VoteToOperator(opts *bind.CallOpts, arg0 []byte) (common.Address, error) {
	var out []interface{}
	err := _StakeHub.contract.Call(opts, &out, "voteToOperator", arg0)
	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err
}

// VoteToOperator is a free data retrieval call binding the contract method 0x17b4f353.
//
// Solidity: function voteToOperator(bytes ) view returns(address)
func (_StakeHub *StakeHubSession) VoteToOperator(arg0 []byte) (common.Address, error) {
	return _StakeHub.Contract.VoteToOperator(&_StakeHub.CallOpts, arg0)
}

// VoteToOperator is a free data retrieval call binding the contract method 0x17b4f353.
//
// Solidity: function voteToOperator(bytes ) view returns(address)
func (_StakeHub *StakeHubCallerSession) VoteToOperator(arg0 []byte) (common.Address, error) {
	return _StakeHub.Contract.VoteToOperator(&_StakeHub.CallOpts, arg0)
}

// AddToBlackList is a paid mutator transaction binding the contract method 0x417c73a7.
//
// Solidity: function addToBlackList(address account) returns()
func (_StakeHub *StakeHubTransactor) AddToBlackList(opts *bind.TransactOpts, account common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "addToBlackList", account)
}

// AddToBlackList is a paid mutator transaction binding the contract method 0x417c73a7.
//
// Solidity: function addToBlackList(address account) returns()
func (_StakeHub *StakeHubSession) AddToBlackList(account common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.AddToBlackList(&_StakeHub.TransactOpts, account)
}

// AddToBlackList is a paid mutator transaction binding the contract method 0x417c73a7.
//
// Solidity: function addToBlackList(address account) returns()
func (_StakeHub *StakeHubTransactorSession) AddToBlackList(account common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.AddToBlackList(&_StakeHub.TransactOpts, account)
}

// Claim is a paid mutator transaction binding the contract method 0xaad3ec96.
//
// Solidity: function claim(address operatorAddress, uint256 requestNumber) returns()
func (_StakeHub *StakeHubTransactor) Claim(opts *bind.TransactOpts, operatorAddress common.Address, requestNumber *big.Int) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "claim", operatorAddress, requestNumber)
}

// Claim is a paid mutator transaction binding the contract method 0xaad3ec96.
//
// Solidity: function claim(address operatorAddress, uint256 requestNumber) returns()
func (_StakeHub *StakeHubSession) Claim(operatorAddress common.Address, requestNumber *big.Int) (*types.Transaction, error) {
	return _StakeHub.Contract.Claim(&_StakeHub.TransactOpts, operatorAddress, requestNumber)
}

// Claim is a paid mutator transaction binding the contract method 0xaad3ec96.
//
// Solidity: function claim(address operatorAddress, uint256 requestNumber) returns()
func (_StakeHub *StakeHubTransactorSession) Claim(operatorAddress common.Address, requestNumber *big.Int) (*types.Transaction, error) {
	return _StakeHub.Contract.Claim(&_StakeHub.TransactOpts, operatorAddress, requestNumber)
}

// ClaimBatch is a paid mutator transaction binding the contract method 0xd7c2dfc8.
//
// Solidity: function claimBatch(address[] operatorAddresses, uint256[] requestNumbers) returns()
func (_StakeHub *StakeHubTransactor) ClaimBatch(opts *bind.TransactOpts, operatorAddresses []common.Address, requestNumbers []*big.Int) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "claimBatch", operatorAddresses, requestNumbers)
}

// ClaimBatch is a paid mutator transaction binding the contract method 0xd7c2dfc8.
//
// Solidity: function claimBatch(address[] operatorAddresses, uint256[] requestNumbers) returns()
func (_StakeHub *StakeHubSession) ClaimBatch(operatorAddresses []common.Address, requestNumbers []*big.Int) (*types.Transaction, error) {
	return _StakeHub.Contract.ClaimBatch(&_StakeHub.TransactOpts, operatorAddresses, requestNumbers)
}

// ClaimBatch is a paid mutator transaction binding the contract method 0xd7c2dfc8.
//
// Solidity: function claimBatch(address[] operatorAddresses, uint256[] requestNumbers) returns()
func (_StakeHub *StakeHubTransactorSession) ClaimBatch(operatorAddresses []common.Address, requestNumbers []*big.Int) (*types.Transaction, error) {
	return _StakeHub.Contract.ClaimBatch(&_StakeHub.TransactOpts, operatorAddresses, requestNumbers)
}

// CreateValidator is a paid mutator transaction binding the contract method 0x64028fbd.
//
// Solidity: function createValidator(address consensusAddress, bytes voteAddress, bytes blsProof, (uint64,uint64,uint64) commission, (string,string,string,string) description) payable returns()
func (_StakeHub *StakeHubTransactor) CreateValidator(opts *bind.TransactOpts, consensusAddress common.Address, voteAddress []byte, blsProof []byte, commission StakeHubCommission, description StakeHubDescription) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "createValidator", consensusAddress, voteAddress, blsProof, commission, description)
}

// CreateValidator is a paid mutator transaction binding the contract method 0x64028fbd.
//
// Solidity: function createValidator(address consensusAddress, bytes voteAddress, bytes blsProof, (uint64,uint64,uint64) commission, (string,string,string,string) description) payable returns()
func (_StakeHub *StakeHubSession) CreateValidator(consensusAddress common.Address, voteAddress []byte, blsProof []byte, commission StakeHubCommission, description StakeHubDescription) (*types.Transaction, error) {
	return _StakeHub.Contract.CreateValidator(&_StakeHub.TransactOpts, consensusAddress, voteAddress, blsProof, commission, description)
}

// CreateValidator is a paid mutator transaction binding the contract method 0x64028fbd.
//
// Solidity: function createValidator(address consensusAddress, bytes voteAddress, bytes blsProof, (uint64,uint64,uint64) commission, (string,string,string,string) description) payable returns()
func (_StakeHub *StakeHubTransactorSession) CreateValidator(consensusAddress common.Address, voteAddress []byte, blsProof []byte, commission StakeHubCommission, description StakeHubDescription) (*types.Transaction, error) {
	return _StakeHub.Contract.CreateValidator(&_StakeHub.TransactOpts, consensusAddress, voteAddress, blsProof, commission, description)
}

// Delegate is a paid mutator transaction binding the contract method 0x982ef0a7.
//
// Solidity: function delegate(address operatorAddress, bool delegateVotePower) payable returns()
func (_StakeHub *StakeHubTransactor) Delegate(opts *bind.TransactOpts, operatorAddress common.Address, delegateVotePower bool) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "delegate", operatorAddress, delegateVotePower)
}

// Delegate is a paid mutator transaction binding the contract method 0x982ef0a7.
//
// Solidity: function delegate(address operatorAddress, bool delegateVotePower) payable returns()
func (_StakeHub *StakeHubSession) Delegate(operatorAddress common.Address, delegateVotePower bool) (*types.Transaction, error) {
	return _StakeHub.Contract.Delegate(&_StakeHub.TransactOpts, operatorAddress, delegateVotePower)
}

// Delegate is a paid mutator transaction binding the contract method 0x982ef0a7.
//
// Solidity: function delegate(address operatorAddress, bool delegateVotePower) payable returns()
func (_StakeHub *StakeHubTransactorSession) Delegate(operatorAddress common.Address, delegateVotePower bool) (*types.Transaction, error) {
	return _StakeHub.Contract.Delegate(&_StakeHub.TransactOpts, operatorAddress, delegateVotePower)
}

// DistributeReward is a paid mutator transaction binding the contract method 0x092193ab.
//
// Solidity: function distributeReward(address consensusAddress) payable returns()
func (_StakeHub *StakeHubTransactor) DistributeReward(opts *bind.TransactOpts, consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "distributeReward", consensusAddress)
}

// DistributeReward is a paid mutator transaction binding the contract method 0x092193ab.
//
// Solidity: function distributeReward(address consensusAddress) payable returns()
func (_StakeHub *StakeHubSession) DistributeReward(consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.DistributeReward(&_StakeHub.TransactOpts, consensusAddress)
}

// DistributeReward is a paid mutator transaction binding the contract method 0x092193ab.
//
// Solidity: function distributeReward(address consensusAddress) payable returns()
func (_StakeHub *StakeHubTransactorSession) DistributeReward(consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.DistributeReward(&_StakeHub.TransactOpts, consensusAddress)
}

// DoubleSignSlash is a paid mutator transaction binding the contract method 0xc38fbec8.
//
// Solidity: function doubleSignSlash(address consensusAddress) returns()
func (_StakeHub *StakeHubTransactor) DoubleSignSlash(opts *bind.TransactOpts, consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "doubleSignSlash", consensusAddress)
}

// DoubleSignSlash is a paid mutator transaction binding the contract method 0xc38fbec8.
//
// Solidity: function doubleSignSlash(address consensusAddress) returns()
func (_StakeHub *StakeHubSession) DoubleSignSlash(consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.DoubleSignSlash(&_StakeHub.TransactOpts, consensusAddress)
}

// DoubleSignSlash is a paid mutator transaction binding the contract method 0xc38fbec8.
//
// Solidity: function doubleSignSlash(address consensusAddress) returns()
func (_StakeHub *StakeHubTransactorSession) DoubleSignSlash(consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.DoubleSignSlash(&_StakeHub.TransactOpts, consensusAddress)
}

// DowntimeSlash is a paid mutator transaction binding the contract method 0x75cc7d89.
//
// Solidity: function downtimeSlash(address consensusAddress) returns()
func (_StakeHub *StakeHubTransactor) DowntimeSlash(opts *bind.TransactOpts, consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "downtimeSlash", consensusAddress)
}

// DowntimeSlash is a paid mutator transaction binding the contract method 0x75cc7d89.
//
// Solidity: function downtimeSlash(address consensusAddress) returns()
func (_StakeHub *StakeHubSession) DowntimeSlash(consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.DowntimeSlash(&_StakeHub.TransactOpts, consensusAddress)
}

// DowntimeSlash is a paid mutator transaction binding the contract method 0x75cc7d89.
//
// Solidity: function downtimeSlash(address consensusAddress) returns()
func (_StakeHub *StakeHubTransactorSession) DowntimeSlash(consensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.DowntimeSlash(&_StakeHub.TransactOpts, consensusAddress)
}

// EditCommissionRate is a paid mutator transaction binding the contract method 0x5e7cc1c9.
//
// Solidity: function editCommissionRate(uint64 commissionRate) returns()
func (_StakeHub *StakeHubTransactor) EditCommissionRate(opts *bind.TransactOpts, commissionRate uint64) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "editCommissionRate", commissionRate)
}

// EditCommissionRate is a paid mutator transaction binding the contract method 0x5e7cc1c9.
//
// Solidity: function editCommissionRate(uint64 commissionRate) returns()
func (_StakeHub *StakeHubSession) EditCommissionRate(commissionRate uint64) (*types.Transaction, error) {
	return _StakeHub.Contract.EditCommissionRate(&_StakeHub.TransactOpts, commissionRate)
}

// EditCommissionRate is a paid mutator transaction binding the contract method 0x5e7cc1c9.
//
// Solidity: function editCommissionRate(uint64 commissionRate) returns()
func (_StakeHub *StakeHubTransactorSession) EditCommissionRate(commissionRate uint64) (*types.Transaction, error) {
	return _StakeHub.Contract.EditCommissionRate(&_StakeHub.TransactOpts, commissionRate)
}

// EditConsensusAddress is a paid mutator transaction binding the contract method 0x45211bfd.
//
// Solidity: function editConsensusAddress(address newConsensusAddress) returns()
func (_StakeHub *StakeHubTransactor) EditConsensusAddress(opts *bind.TransactOpts, newConsensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "editConsensusAddress", newConsensusAddress)
}

// EditConsensusAddress is a paid mutator transaction binding the contract method 0x45211bfd.
//
// Solidity: function editConsensusAddress(address newConsensusAddress) returns()
func (_StakeHub *StakeHubSession) EditConsensusAddress(newConsensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.EditConsensusAddress(&_StakeHub.TransactOpts, newConsensusAddress)
}

// EditConsensusAddress is a paid mutator transaction binding the contract method 0x45211bfd.
//
// Solidity: function editConsensusAddress(address newConsensusAddress) returns()
func (_StakeHub *StakeHubTransactorSession) EditConsensusAddress(newConsensusAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.EditConsensusAddress(&_StakeHub.TransactOpts, newConsensusAddress)
}

// EditDescription is a paid mutator transaction binding the contract method 0xd6ca429d.
//
// Solidity: function editDescription((string,string,string,string) description) returns()
func (_StakeHub *StakeHubTransactor) EditDescription(opts *bind.TransactOpts, description StakeHubDescription) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "editDescription", description)
}

// EditDescription is a paid mutator transaction binding the contract method 0xd6ca429d.
//
// Solidity: function editDescription((string,string,string,string) description) returns()
func (_StakeHub *StakeHubSession) EditDescription(description StakeHubDescription) (*types.Transaction, error) {
	return _StakeHub.Contract.EditDescription(&_StakeHub.TransactOpts, description)
}

// EditDescription is a paid mutator transaction binding the contract method 0xd6ca429d.
//
// Solidity: function editDescription((string,string,string,string) description) returns()
func (_StakeHub *StakeHubTransactorSession) EditDescription(description StakeHubDescription) (*types.Transaction, error) {
	return _StakeHub.Contract.EditDescription(&_StakeHub.TransactOpts, description)
}

// EditVoteAddress is a paid mutator transaction binding the contract method 0xfb50b31f.
//
// Solidity: function editVoteAddress(bytes newVoteAddress, bytes blsProof) returns()
func (_StakeHub *StakeHubTransactor) EditVoteAddress(opts *bind.TransactOpts, newVoteAddress []byte, blsProof []byte) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "editVoteAddress", newVoteAddress, blsProof)
}

// EditVoteAddress is a paid mutator transaction binding the contract method 0xfb50b31f.
//
// Solidity: function editVoteAddress(bytes newVoteAddress, bytes blsProof) returns()
func (_StakeHub *StakeHubSession) EditVoteAddress(newVoteAddress []byte, blsProof []byte) (*types.Transaction, error) {
	return _StakeHub.Contract.EditVoteAddress(&_StakeHub.TransactOpts, newVoteAddress, blsProof)
}

// EditVoteAddress is a paid mutator transaction binding the contract method 0xfb50b31f.
//
// Solidity: function editVoteAddress(bytes newVoteAddress, bytes blsProof) returns()
func (_StakeHub *StakeHubTransactorSession) EditVoteAddress(newVoteAddress []byte, blsProof []byte) (*types.Transaction, error) {
	return _StakeHub.Contract.EditVoteAddress(&_StakeHub.TransactOpts, newVoteAddress, blsProof)
}

// Initialize is a paid mutator transaction binding the contract method 0x8129fc1c.
//
// Solidity: function initialize() returns()
func (_StakeHub *StakeHubTransactor) Initialize(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "initialize")
}

// Initialize is a paid mutator transaction binding the contract method 0x8129fc1c.
//
// Solidity: function initialize() returns()
func (_StakeHub *StakeHubSession) Initialize() (*types.Transaction, error) {
	return _StakeHub.Contract.Initialize(&_StakeHub.TransactOpts)
}

// Initialize is a paid mutator transaction binding the contract method 0x8129fc1c.
//
// Solidity: function initialize() returns()
func (_StakeHub *StakeHubTransactorSession) Initialize() (*types.Transaction, error) {
	return _StakeHub.Contract.Initialize(&_StakeHub.TransactOpts)
}

// MaliciousVoteSlash is a paid mutator transaction binding the contract method 0x0e9fbf51.
//
// Solidity: function maliciousVoteSlash(bytes voteAddress) returns()
func (_StakeHub *StakeHubTransactor) MaliciousVoteSlash(opts *bind.TransactOpts, voteAddress []byte) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "maliciousVoteSlash", voteAddress)
}

// MaliciousVoteSlash is a paid mutator transaction binding the contract method 0x0e9fbf51.
//
// Solidity: function maliciousVoteSlash(bytes voteAddress) returns()
func (_StakeHub *StakeHubSession) MaliciousVoteSlash(voteAddress []byte) (*types.Transaction, error) {
	return _StakeHub.Contract.MaliciousVoteSlash(&_StakeHub.TransactOpts, voteAddress)
}

// MaliciousVoteSlash is a paid mutator transaction binding the contract method 0x0e9fbf51.
//
// Solidity: function maliciousVoteSlash(bytes voteAddress) returns()
func (_StakeHub *StakeHubTransactorSession) MaliciousVoteSlash(voteAddress []byte) (*types.Transaction, error) {
	return _StakeHub.Contract.MaliciousVoteSlash(&_StakeHub.TransactOpts, voteAddress)
}

// Pause is a paid mutator transaction binding the contract method 0x8456cb59.
//
// Solidity: function pause() returns()
func (_StakeHub *StakeHubTransactor) Pause(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "pause")
}

// Pause is a paid mutator transaction binding the contract method 0x8456cb59.
//
// Solidity: function pause() returns()
func (_StakeHub *StakeHubSession) Pause() (*types.Transaction, error) {
	return _StakeHub.Contract.Pause(&_StakeHub.TransactOpts)
}

// Pause is a paid mutator transaction binding the contract method 0x8456cb59.
//
// Solidity: function pause() returns()
func (_StakeHub *StakeHubTransactorSession) Pause() (*types.Transaction, error) {
	return _StakeHub.Contract.Pause(&_StakeHub.TransactOpts)
}

// Redelegate is a paid mutator transaction binding the contract method 0x59491871.
//
// Solidity: function redelegate(address srcValidator, address dstValidator, uint256 shares, bool delegateVotePower) returns()
func (_StakeHub *StakeHubTransactor) Redelegate(opts *bind.TransactOpts, srcValidator common.Address, dstValidator common.Address, shares *big.Int, delegateVotePower bool) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "redelegate", srcValidator, dstValidator, shares, delegateVotePower)
}

// Redelegate is a paid mutator transaction binding the contract method 0x59491871.
//
// Solidity: function redelegate(address srcValidator, address dstValidator, uint256 shares, bool delegateVotePower) returns()
func (_StakeHub *StakeHubSession) Redelegate(srcValidator common.Address, dstValidator common.Address, shares *big.Int, delegateVotePower bool) (*types.Transaction, error) {
	return _StakeHub.Contract.Redelegate(&_StakeHub.TransactOpts, srcValidator, dstValidator, shares, delegateVotePower)
}

// Redelegate is a paid mutator transaction binding the contract method 0x59491871.
//
// Solidity: function redelegate(address srcValidator, address dstValidator, uint256 shares, bool delegateVotePower) returns()
func (_StakeHub *StakeHubTransactorSession) Redelegate(srcValidator common.Address, dstValidator common.Address, shares *big.Int, delegateVotePower bool) (*types.Transaction, error) {
	return _StakeHub.Contract.Redelegate(&_StakeHub.TransactOpts, srcValidator, dstValidator, shares, delegateVotePower)
}

// RemoveFromBlackList is a paid mutator transaction binding the contract method 0x4a49ac4c.
//
// Solidity: function removeFromBlackList(address account) returns()
func (_StakeHub *StakeHubTransactor) RemoveFromBlackList(opts *bind.TransactOpts, account common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "removeFromBlackList", account)
}

// RemoveFromBlackList is a paid mutator transaction binding the contract method 0x4a49ac4c.
//
// Solidity: function removeFromBlackList(address account) returns()
func (_StakeHub *StakeHubSession) RemoveFromBlackList(account common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.RemoveFromBlackList(&_StakeHub.TransactOpts, account)
}

// RemoveFromBlackList is a paid mutator transaction binding the contract method 0x4a49ac4c.
//
// Solidity: function removeFromBlackList(address account) returns()
func (_StakeHub *StakeHubTransactorSession) RemoveFromBlackList(account common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.RemoveFromBlackList(&_StakeHub.TransactOpts, account)
}

// Resume is a paid mutator transaction binding the contract method 0x046f7da2.
//
// Solidity: function resume() returns()
func (_StakeHub *StakeHubTransactor) Resume(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "resume")
}

// Resume is a paid mutator transaction binding the contract method 0x046f7da2.
//
// Solidity: function resume() returns()
func (_StakeHub *StakeHubSession) Resume() (*types.Transaction, error) {
	return _StakeHub.Contract.Resume(&_StakeHub.TransactOpts)
}

// Resume is a paid mutator transaction binding the contract method 0x046f7da2.
//
// Solidity: function resume() returns()
func (_StakeHub *StakeHubTransactorSession) Resume() (*types.Transaction, error) {
	return _StakeHub.Contract.Resume(&_StakeHub.TransactOpts)
}

// SyncGovToken is a paid mutator transaction binding the contract method 0xbaa7199e.
//
// Solidity: function syncGovToken(address[] operatorAddresses, address account) returns()
func (_StakeHub *StakeHubTransactor) SyncGovToken(opts *bind.TransactOpts, operatorAddresses []common.Address, account common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "syncGovToken", operatorAddresses, account)
}

// SyncGovToken is a paid mutator transaction binding the contract method 0xbaa7199e.
//
// Solidity: function syncGovToken(address[] operatorAddresses, address account) returns()
func (_StakeHub *StakeHubSession) SyncGovToken(operatorAddresses []common.Address, account common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.SyncGovToken(&_StakeHub.TransactOpts, operatorAddresses, account)
}

// SyncGovToken is a paid mutator transaction binding the contract method 0xbaa7199e.
//
// Solidity: function syncGovToken(address[] operatorAddresses, address account) returns()
func (_StakeHub *StakeHubTransactorSession) SyncGovToken(operatorAddresses []common.Address, account common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.SyncGovToken(&_StakeHub.TransactOpts, operatorAddresses, account)
}

// Undelegate is a paid mutator transaction binding the contract method 0x4d99dd16.
//
// Solidity: function undelegate(address operatorAddress, uint256 shares) returns()
func (_StakeHub *StakeHubTransactor) Undelegate(opts *bind.TransactOpts, operatorAddress common.Address, shares *big.Int) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "undelegate", operatorAddress, shares)
}

// Undelegate is a paid mutator transaction binding the contract method 0x4d99dd16.
//
// Solidity: function undelegate(address operatorAddress, uint256 shares) returns()
func (_StakeHub *StakeHubSession) Undelegate(operatorAddress common.Address, shares *big.Int) (*types.Transaction, error) {
	return _StakeHub.Contract.Undelegate(&_StakeHub.TransactOpts, operatorAddress, shares)
}

// Undelegate is a paid mutator transaction binding the contract method 0x4d99dd16.
//
// Solidity: function undelegate(address operatorAddress, uint256 shares) returns()
func (_StakeHub *StakeHubTransactorSession) Undelegate(operatorAddress common.Address, shares *big.Int) (*types.Transaction, error) {
	return _StakeHub.Contract.Undelegate(&_StakeHub.TransactOpts, operatorAddress, shares)
}

// Unjail is a paid mutator transaction binding the contract method 0x449ecfe6.
//
// Solidity: function unjail(address operatorAddress) returns()
func (_StakeHub *StakeHubTransactor) Unjail(opts *bind.TransactOpts, operatorAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "unjail", operatorAddress)
}

// Unjail is a paid mutator transaction binding the contract method 0x449ecfe6.
//
// Solidity: function unjail(address operatorAddress) returns()
func (_StakeHub *StakeHubSession) Unjail(operatorAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.Unjail(&_StakeHub.TransactOpts, operatorAddress)
}

// Unjail is a paid mutator transaction binding the contract method 0x449ecfe6.
//
// Solidity: function unjail(address operatorAddress) returns()
func (_StakeHub *StakeHubTransactorSession) Unjail(operatorAddress common.Address) (*types.Transaction, error) {
	return _StakeHub.Contract.Unjail(&_StakeHub.TransactOpts, operatorAddress)
}

// UpdateParam is a paid mutator transaction binding the contract method 0xac431751.
//
// Solidity: function updateParam(string key, bytes value) returns()
func (_StakeHub *StakeHubTransactor) UpdateParam(opts *bind.TransactOpts, key string, value []byte) (*types.Transaction, error) {
	return _StakeHub.contract.Transact(opts, "updateParam", key, value)
}

// UpdateParam is a paid mutator transaction binding the contract method 0xac431751.
//
// Solidity: function updateParam(string key, bytes value) returns()
func (_StakeHub *StakeHubSession) UpdateParam(key string, value []byte) (*types.Transaction, error) {
	return _StakeHub.Contract.UpdateParam(&_StakeHub.TransactOpts, key, value)
}

// UpdateParam is a paid mutator transaction binding the contract method 0xac431751.
//
// Solidity: function updateParam(string key, bytes value) returns()
func (_StakeHub *StakeHubTransactorSession) UpdateParam(key string, value []byte) (*types.Transaction, error) {
	return _StakeHub.Contract.UpdateParam(&_StakeHub.TransactOpts, key, value)
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_StakeHub *StakeHubTransactor) Receive(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StakeHub.contract.RawTransact(opts, nil) // calldata is disallowed for receive function
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_StakeHub *StakeHubSession) Receive() (*types.Transaction, error) {
	return _StakeHub.Contract.Receive(&_StakeHub.TransactOpts)
}

// Receive is a paid mutator transaction binding the contract receive function.
//
// Solidity: receive() payable returns()
func (_StakeHub *StakeHubTransactorSession) Receive() (*types.Transaction, error) {
	return _StakeHub.Contract.Receive(&_StakeHub.TransactOpts)
}

// StakeHubClaimedIterator is returned from FilterClaimed and is used to iterate over the raw logs and unpacked data for Claimed events raised by the StakeHub contract.
type StakeHubClaimedIterator struct {
	Event *StakeHubClaimed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubClaimedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubClaimed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubClaimed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubClaimedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubClaimedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubClaimed represents a Claimed event raised by the StakeHub contract.
type StakeHubClaimed struct {
	OperatorAddress common.Address
	Delegator       common.Address
	BnbAmount       *big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterClaimed is a free log retrieval operation binding the contract event 0xf7a40077ff7a04c7e61f6f26fb13774259ddf1b6bce9ecf26a8276cdd3992683.
//
// Solidity: event Claimed(address indexed operatorAddress, address indexed delegator, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) FilterClaimed(opts *bind.FilterOpts, operatorAddress []common.Address, delegator []common.Address) (*StakeHubClaimedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Claimed", operatorAddressRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubClaimedIterator{contract: _StakeHub.contract, event: "Claimed", logs: logs, sub: sub}, nil
}

// WatchClaimed is a free log subscription operation binding the contract event 0xf7a40077ff7a04c7e61f6f26fb13774259ddf1b6bce9ecf26a8276cdd3992683.
//
// Solidity: event Claimed(address indexed operatorAddress, address indexed delegator, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) WatchClaimed(opts *bind.WatchOpts, sink chan<- *StakeHubClaimed, operatorAddress []common.Address, delegator []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Claimed", operatorAddressRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubClaimed)
				if err := _StakeHub.contract.UnpackLog(event, "Claimed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseClaimed is a log parse operation binding the contract event 0xf7a40077ff7a04c7e61f6f26fb13774259ddf1b6bce9ecf26a8276cdd3992683.
//
// Solidity: event Claimed(address indexed operatorAddress, address indexed delegator, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) ParseClaimed(log types.Log) (*StakeHubClaimed, error) {
	event := new(StakeHubClaimed)
	if err := _StakeHub.contract.UnpackLog(event, "Claimed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubCommissionRateEditedIterator is returned from FilterCommissionRateEdited and is used to iterate over the raw logs and unpacked data for CommissionRateEdited events raised by the StakeHub contract.
type StakeHubCommissionRateEditedIterator struct {
	Event *StakeHubCommissionRateEdited // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubCommissionRateEditedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubCommissionRateEdited)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubCommissionRateEdited)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubCommissionRateEditedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubCommissionRateEditedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubCommissionRateEdited represents a CommissionRateEdited event raised by the StakeHub contract.
type StakeHubCommissionRateEdited struct {
	OperatorAddress common.Address
	CommissionRate  uint64
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterCommissionRateEdited is a free log retrieval operation binding the contract event 0x78cdd96edf59e09cfd4d26ef6ef6c92d166effe6a40970c54821206d541932cb.
//
// Solidity: event CommissionRateEdited(address indexed operatorAddress, uint64 commissionRate)
func (_StakeHub *StakeHubFilterer) FilterCommissionRateEdited(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubCommissionRateEditedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "CommissionRateEdited", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubCommissionRateEditedIterator{contract: _StakeHub.contract, event: "CommissionRateEdited", logs: logs, sub: sub}, nil
}

// WatchCommissionRateEdited is a free log subscription operation binding the contract event 0x78cdd96edf59e09cfd4d26ef6ef6c92d166effe6a40970c54821206d541932cb.
//
// Solidity: event CommissionRateEdited(address indexed operatorAddress, uint64 commissionRate)
func (_StakeHub *StakeHubFilterer) WatchCommissionRateEdited(opts *bind.WatchOpts, sink chan<- *StakeHubCommissionRateEdited, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "CommissionRateEdited", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubCommissionRateEdited)
				if err := _StakeHub.contract.UnpackLog(event, "CommissionRateEdited", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseCommissionRateEdited is a log parse operation binding the contract event 0x78cdd96edf59e09cfd4d26ef6ef6c92d166effe6a40970c54821206d541932cb.
//
// Solidity: event CommissionRateEdited(address indexed operatorAddress, uint64 commissionRate)
func (_StakeHub *StakeHubFilterer) ParseCommissionRateEdited(log types.Log) (*StakeHubCommissionRateEdited, error) {
	event := new(StakeHubCommissionRateEdited)
	if err := _StakeHub.contract.UnpackLog(event, "CommissionRateEdited", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubConsensusAddressEditedIterator is returned from FilterConsensusAddressEdited and is used to iterate over the raw logs and unpacked data for ConsensusAddressEdited events raised by the StakeHub contract.
type StakeHubConsensusAddressEditedIterator struct {
	Event *StakeHubConsensusAddressEdited // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubConsensusAddressEditedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubConsensusAddressEdited)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubConsensusAddressEdited)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubConsensusAddressEditedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubConsensusAddressEditedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubConsensusAddressEdited represents a ConsensusAddressEdited event raised by the StakeHub contract.
type StakeHubConsensusAddressEdited struct {
	OperatorAddress     common.Address
	NewConsensusAddress common.Address
	Raw                 types.Log // Blockchain specific contextual infos
}

// FilterConsensusAddressEdited is a free log retrieval operation binding the contract event 0x6e4e747ca35203f16401c69805c7dd52fff67ef60b0ebc5c7fe16890530f2235.
//
// Solidity: event ConsensusAddressEdited(address indexed operatorAddress, address indexed newConsensusAddress)
func (_StakeHub *StakeHubFilterer) FilterConsensusAddressEdited(opts *bind.FilterOpts, operatorAddress []common.Address, newConsensusAddress []common.Address) (*StakeHubConsensusAddressEditedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var newConsensusAddressRule []interface{}
	for _, newConsensusAddressItem := range newConsensusAddress {
		newConsensusAddressRule = append(newConsensusAddressRule, newConsensusAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ConsensusAddressEdited", operatorAddressRule, newConsensusAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubConsensusAddressEditedIterator{contract: _StakeHub.contract, event: "ConsensusAddressEdited", logs: logs, sub: sub}, nil
}

// WatchConsensusAddressEdited is a free log subscription operation binding the contract event 0x6e4e747ca35203f16401c69805c7dd52fff67ef60b0ebc5c7fe16890530f2235.
//
// Solidity: event ConsensusAddressEdited(address indexed operatorAddress, address indexed newConsensusAddress)
func (_StakeHub *StakeHubFilterer) WatchConsensusAddressEdited(opts *bind.WatchOpts, sink chan<- *StakeHubConsensusAddressEdited, operatorAddress []common.Address, newConsensusAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var newConsensusAddressRule []interface{}
	for _, newConsensusAddressItem := range newConsensusAddress {
		newConsensusAddressRule = append(newConsensusAddressRule, newConsensusAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ConsensusAddressEdited", operatorAddressRule, newConsensusAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubConsensusAddressEdited)
				if err := _StakeHub.contract.UnpackLog(event, "ConsensusAddressEdited", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseConsensusAddressEdited is a log parse operation binding the contract event 0x6e4e747ca35203f16401c69805c7dd52fff67ef60b0ebc5c7fe16890530f2235.
//
// Solidity: event ConsensusAddressEdited(address indexed operatorAddress, address indexed newConsensusAddress)
func (_StakeHub *StakeHubFilterer) ParseConsensusAddressEdited(log types.Log) (*StakeHubConsensusAddressEdited, error) {
	event := new(StakeHubConsensusAddressEdited)
	if err := _StakeHub.contract.UnpackLog(event, "ConsensusAddressEdited", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubDelegatedIterator is returned from FilterDelegated and is used to iterate over the raw logs and unpacked data for Delegated events raised by the StakeHub contract.
type StakeHubDelegatedIterator struct {
	Event *StakeHubDelegated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubDelegatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubDelegated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubDelegated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubDelegatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubDelegatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubDelegated represents a Delegated event raised by the StakeHub contract.
type StakeHubDelegated struct {
	OperatorAddress common.Address
	Delegator       common.Address
	Shares          *big.Int
	BnbAmount       *big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterDelegated is a free log retrieval operation binding the contract event 0x24d7bda8602b916d64417f0dbfe2e2e88ec9b1157bd9f596dfdb91ba26624e04.
//
// Solidity: event Delegated(address indexed operatorAddress, address indexed delegator, uint256 shares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) FilterDelegated(opts *bind.FilterOpts, operatorAddress []common.Address, delegator []common.Address) (*StakeHubDelegatedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Delegated", operatorAddressRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubDelegatedIterator{contract: _StakeHub.contract, event: "Delegated", logs: logs, sub: sub}, nil
}

// WatchDelegated is a free log subscription operation binding the contract event 0x24d7bda8602b916d64417f0dbfe2e2e88ec9b1157bd9f596dfdb91ba26624e04.
//
// Solidity: event Delegated(address indexed operatorAddress, address indexed delegator, uint256 shares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) WatchDelegated(opts *bind.WatchOpts, sink chan<- *StakeHubDelegated, operatorAddress []common.Address, delegator []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Delegated", operatorAddressRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubDelegated)
				if err := _StakeHub.contract.UnpackLog(event, "Delegated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDelegated is a log parse operation binding the contract event 0x24d7bda8602b916d64417f0dbfe2e2e88ec9b1157bd9f596dfdb91ba26624e04.
//
// Solidity: event Delegated(address indexed operatorAddress, address indexed delegator, uint256 shares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) ParseDelegated(log types.Log) (*StakeHubDelegated, error) {
	event := new(StakeHubDelegated)
	if err := _StakeHub.contract.UnpackLog(event, "Delegated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubDescriptionEditedIterator is returned from FilterDescriptionEdited and is used to iterate over the raw logs and unpacked data for DescriptionEdited events raised by the StakeHub contract.
type StakeHubDescriptionEditedIterator struct {
	Event *StakeHubDescriptionEdited // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubDescriptionEditedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubDescriptionEdited)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubDescriptionEdited)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubDescriptionEditedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubDescriptionEditedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubDescriptionEdited represents a DescriptionEdited event raised by the StakeHub contract.
type StakeHubDescriptionEdited struct {
	OperatorAddress common.Address
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterDescriptionEdited is a free log retrieval operation binding the contract event 0x85d6366b336ade7f106987ec7a8eac1e8799e508aeab045a39d2f63e0dc969d9.
//
// Solidity: event DescriptionEdited(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) FilterDescriptionEdited(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubDescriptionEditedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "DescriptionEdited", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubDescriptionEditedIterator{contract: _StakeHub.contract, event: "DescriptionEdited", logs: logs, sub: sub}, nil
}

// WatchDescriptionEdited is a free log subscription operation binding the contract event 0x85d6366b336ade7f106987ec7a8eac1e8799e508aeab045a39d2f63e0dc969d9.
//
// Solidity: event DescriptionEdited(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) WatchDescriptionEdited(opts *bind.WatchOpts, sink chan<- *StakeHubDescriptionEdited, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "DescriptionEdited", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubDescriptionEdited)
				if err := _StakeHub.contract.UnpackLog(event, "DescriptionEdited", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDescriptionEdited is a log parse operation binding the contract event 0x85d6366b336ade7f106987ec7a8eac1e8799e508aeab045a39d2f63e0dc969d9.
//
// Solidity: event DescriptionEdited(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) ParseDescriptionEdited(log types.Log) (*StakeHubDescriptionEdited, error) {
	event := new(StakeHubDescriptionEdited)
	if err := _StakeHub.contract.UnpackLog(event, "DescriptionEdited", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubInitializedIterator is returned from FilterInitialized and is used to iterate over the raw logs and unpacked data for Initialized events raised by the StakeHub contract.
type StakeHubInitializedIterator struct {
	Event *StakeHubInitialized // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubInitializedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubInitialized)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubInitialized)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubInitializedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubInitializedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubInitialized represents a Initialized event raised by the StakeHub contract.
type StakeHubInitialized struct {
	Version uint8
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterInitialized is a free log retrieval operation binding the contract event 0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498.
//
// Solidity: event Initialized(uint8 version)
func (_StakeHub *StakeHubFilterer) FilterInitialized(opts *bind.FilterOpts) (*StakeHubInitializedIterator, error) {
	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Initialized")
	if err != nil {
		return nil, err
	}
	return &StakeHubInitializedIterator{contract: _StakeHub.contract, event: "Initialized", logs: logs, sub: sub}, nil
}

// WatchInitialized is a free log subscription operation binding the contract event 0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498.
//
// Solidity: event Initialized(uint8 version)
func (_StakeHub *StakeHubFilterer) WatchInitialized(opts *bind.WatchOpts, sink chan<- *StakeHubInitialized) (event.Subscription, error) {
	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Initialized")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubInitialized)
				if err := _StakeHub.contract.UnpackLog(event, "Initialized", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseInitialized is a log parse operation binding the contract event 0x7f26b83ff96e1f2b6a682f133852f6798a09c465da95921460cefb3847402498.
//
// Solidity: event Initialized(uint8 version)
func (_StakeHub *StakeHubFilterer) ParseInitialized(log types.Log) (*StakeHubInitialized, error) {
	event := new(StakeHubInitialized)
	if err := _StakeHub.contract.UnpackLog(event, "Initialized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubParamChangeIterator is returned from FilterParamChange and is used to iterate over the raw logs and unpacked data for ParamChange events raised by the StakeHub contract.
type StakeHubParamChangeIterator struct {
	Event *StakeHubParamChange // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubParamChangeIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubParamChange)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubParamChange)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubParamChangeIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubParamChangeIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubParamChange represents a ParamChange event raised by the StakeHub contract.
type StakeHubParamChange struct {
	Key   string
	Value []byte
	Raw   types.Log // Blockchain specific contextual infos
}

// FilterParamChange is a free log retrieval operation binding the contract event 0xf1ce9b2cbf50eeb05769a29e2543fd350cab46894a7dd9978a12d534bb20e633.
//
// Solidity: event ParamChange(string key, bytes value)
func (_StakeHub *StakeHubFilterer) FilterParamChange(opts *bind.FilterOpts) (*StakeHubParamChangeIterator, error) {
	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ParamChange")
	if err != nil {
		return nil, err
	}
	return &StakeHubParamChangeIterator{contract: _StakeHub.contract, event: "ParamChange", logs: logs, sub: sub}, nil
}

// WatchParamChange is a free log subscription operation binding the contract event 0xf1ce9b2cbf50eeb05769a29e2543fd350cab46894a7dd9978a12d534bb20e633.
//
// Solidity: event ParamChange(string key, bytes value)
func (_StakeHub *StakeHubFilterer) WatchParamChange(opts *bind.WatchOpts, sink chan<- *StakeHubParamChange) (event.Subscription, error) {
	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ParamChange")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubParamChange)
				if err := _StakeHub.contract.UnpackLog(event, "ParamChange", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseParamChange is a log parse operation binding the contract event 0xf1ce9b2cbf50eeb05769a29e2543fd350cab46894a7dd9978a12d534bb20e633.
//
// Solidity: event ParamChange(string key, bytes value)
func (_StakeHub *StakeHubFilterer) ParseParamChange(log types.Log) (*StakeHubParamChange, error) {
	event := new(StakeHubParamChange)
	if err := _StakeHub.contract.UnpackLog(event, "ParamChange", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubPausedIterator is returned from FilterPaused and is used to iterate over the raw logs and unpacked data for Paused events raised by the StakeHub contract.
type StakeHubPausedIterator struct {
	Event *StakeHubPaused // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubPausedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubPaused)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubPaused)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubPausedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubPausedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubPaused represents a Paused event raised by the StakeHub contract.
type StakeHubPaused struct {
	Raw types.Log // Blockchain specific contextual infos
}

// FilterPaused is a free log retrieval operation binding the contract event 0x9e87fac88ff661f02d44f95383c817fece4bce600a3dab7a54406878b965e752.
//
// Solidity: event Paused()
func (_StakeHub *StakeHubFilterer) FilterPaused(opts *bind.FilterOpts) (*StakeHubPausedIterator, error) {
	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Paused")
	if err != nil {
		return nil, err
	}
	return &StakeHubPausedIterator{contract: _StakeHub.contract, event: "Paused", logs: logs, sub: sub}, nil
}

// WatchPaused is a free log subscription operation binding the contract event 0x9e87fac88ff661f02d44f95383c817fece4bce600a3dab7a54406878b965e752.
//
// Solidity: event Paused()
func (_StakeHub *StakeHubFilterer) WatchPaused(opts *bind.WatchOpts, sink chan<- *StakeHubPaused) (event.Subscription, error) {
	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Paused")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubPaused)
				if err := _StakeHub.contract.UnpackLog(event, "Paused", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParsePaused is a log parse operation binding the contract event 0x9e87fac88ff661f02d44f95383c817fece4bce600a3dab7a54406878b965e752.
//
// Solidity: event Paused()
func (_StakeHub *StakeHubFilterer) ParsePaused(log types.Log) (*StakeHubPaused, error) {
	event := new(StakeHubPaused)
	if err := _StakeHub.contract.UnpackLog(event, "Paused", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubRedelegatedIterator is returned from FilterRedelegated and is used to iterate over the raw logs and unpacked data for Redelegated events raised by the StakeHub contract.
type StakeHubRedelegatedIterator struct {
	Event *StakeHubRedelegated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubRedelegatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubRedelegated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubRedelegated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubRedelegatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubRedelegatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubRedelegated represents a Redelegated event raised by the StakeHub contract.
type StakeHubRedelegated struct {
	SrcValidator common.Address
	DstValidator common.Address
	Delegator    common.Address
	OldShares    *big.Int
	NewShares    *big.Int
	BnbAmount    *big.Int
	Raw          types.Log // Blockchain specific contextual infos
}

// FilterRedelegated is a free log retrieval operation binding the contract event 0xfdac6e81913996d95abcc289e90f2d8bd235487ce6fe6f821e7d21002a1915b4.
//
// Solidity: event Redelegated(address indexed srcValidator, address indexed dstValidator, address indexed delegator, uint256 oldShares, uint256 newShares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) FilterRedelegated(opts *bind.FilterOpts, srcValidator []common.Address, dstValidator []common.Address, delegator []common.Address) (*StakeHubRedelegatedIterator, error) {
	var srcValidatorRule []interface{}
	for _, srcValidatorItem := range srcValidator {
		srcValidatorRule = append(srcValidatorRule, srcValidatorItem)
	}
	var dstValidatorRule []interface{}
	for _, dstValidatorItem := range dstValidator {
		dstValidatorRule = append(dstValidatorRule, dstValidatorItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Redelegated", srcValidatorRule, dstValidatorRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubRedelegatedIterator{contract: _StakeHub.contract, event: "Redelegated", logs: logs, sub: sub}, nil
}

// WatchRedelegated is a free log subscription operation binding the contract event 0xfdac6e81913996d95abcc289e90f2d8bd235487ce6fe6f821e7d21002a1915b4.
//
// Solidity: event Redelegated(address indexed srcValidator, address indexed dstValidator, address indexed delegator, uint256 oldShares, uint256 newShares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) WatchRedelegated(opts *bind.WatchOpts, sink chan<- *StakeHubRedelegated, srcValidator []common.Address, dstValidator []common.Address, delegator []common.Address) (event.Subscription, error) {
	var srcValidatorRule []interface{}
	for _, srcValidatorItem := range srcValidator {
		srcValidatorRule = append(srcValidatorRule, srcValidatorItem)
	}
	var dstValidatorRule []interface{}
	for _, dstValidatorItem := range dstValidator {
		dstValidatorRule = append(dstValidatorRule, dstValidatorItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Redelegated", srcValidatorRule, dstValidatorRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubRedelegated)
				if err := _StakeHub.contract.UnpackLog(event, "Redelegated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseRedelegated is a log parse operation binding the contract event 0xfdac6e81913996d95abcc289e90f2d8bd235487ce6fe6f821e7d21002a1915b4.
//
// Solidity: event Redelegated(address indexed srcValidator, address indexed dstValidator, address indexed delegator, uint256 oldShares, uint256 newShares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) ParseRedelegated(log types.Log) (*StakeHubRedelegated, error) {
	event := new(StakeHubRedelegated)
	if err := _StakeHub.contract.UnpackLog(event, "Redelegated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubResumedIterator is returned from FilterResumed and is used to iterate over the raw logs and unpacked data for Resumed events raised by the StakeHub contract.
type StakeHubResumedIterator struct {
	Event *StakeHubResumed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubResumedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubResumed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubResumed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubResumedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubResumedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubResumed represents a Resumed event raised by the StakeHub contract.
type StakeHubResumed struct {
	Raw types.Log // Blockchain specific contextual infos
}

// FilterResumed is a free log retrieval operation binding the contract event 0x62451d457bc659158be6e6247f56ec1df424a5c7597f71c20c2bc44e0965c8f9.
//
// Solidity: event Resumed()
func (_StakeHub *StakeHubFilterer) FilterResumed(opts *bind.FilterOpts) (*StakeHubResumedIterator, error) {
	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Resumed")
	if err != nil {
		return nil, err
	}
	return &StakeHubResumedIterator{contract: _StakeHub.contract, event: "Resumed", logs: logs, sub: sub}, nil
}

// WatchResumed is a free log subscription operation binding the contract event 0x62451d457bc659158be6e6247f56ec1df424a5c7597f71c20c2bc44e0965c8f9.
//
// Solidity: event Resumed()
func (_StakeHub *StakeHubFilterer) WatchResumed(opts *bind.WatchOpts, sink chan<- *StakeHubResumed) (event.Subscription, error) {
	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Resumed")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubResumed)
				if err := _StakeHub.contract.UnpackLog(event, "Resumed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseResumed is a log parse operation binding the contract event 0x62451d457bc659158be6e6247f56ec1df424a5c7597f71c20c2bc44e0965c8f9.
//
// Solidity: event Resumed()
func (_StakeHub *StakeHubFilterer) ParseResumed(log types.Log) (*StakeHubResumed, error) {
	event := new(StakeHubResumed)
	if err := _StakeHub.contract.UnpackLog(event, "Resumed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubRewardDistributeFailedIterator is returned from FilterRewardDistributeFailed and is used to iterate over the raw logs and unpacked data for RewardDistributeFailed events raised by the StakeHub contract.
type StakeHubRewardDistributeFailedIterator struct {
	Event *StakeHubRewardDistributeFailed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubRewardDistributeFailedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubRewardDistributeFailed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubRewardDistributeFailed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubRewardDistributeFailedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubRewardDistributeFailedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubRewardDistributeFailed represents a RewardDistributeFailed event raised by the StakeHub contract.
type StakeHubRewardDistributeFailed struct {
	OperatorAddress common.Address
	FailReason      []byte
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterRewardDistributeFailed is a free log retrieval operation binding the contract event 0xfc8bff675087dd2da069cc3fb517b9ed001e19750c0865241a5542dba1ba170d.
//
// Solidity: event RewardDistributeFailed(address indexed operatorAddress, bytes failReason)
func (_StakeHub *StakeHubFilterer) FilterRewardDistributeFailed(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubRewardDistributeFailedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "RewardDistributeFailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubRewardDistributeFailedIterator{contract: _StakeHub.contract, event: "RewardDistributeFailed", logs: logs, sub: sub}, nil
}

// WatchRewardDistributeFailed is a free log subscription operation binding the contract event 0xfc8bff675087dd2da069cc3fb517b9ed001e19750c0865241a5542dba1ba170d.
//
// Solidity: event RewardDistributeFailed(address indexed operatorAddress, bytes failReason)
func (_StakeHub *StakeHubFilterer) WatchRewardDistributeFailed(opts *bind.WatchOpts, sink chan<- *StakeHubRewardDistributeFailed, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "RewardDistributeFailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubRewardDistributeFailed)
				if err := _StakeHub.contract.UnpackLog(event, "RewardDistributeFailed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseRewardDistributeFailed is a log parse operation binding the contract event 0xfc8bff675087dd2da069cc3fb517b9ed001e19750c0865241a5542dba1ba170d.
//
// Solidity: event RewardDistributeFailed(address indexed operatorAddress, bytes failReason)
func (_StakeHub *StakeHubFilterer) ParseRewardDistributeFailed(log types.Log) (*StakeHubRewardDistributeFailed, error) {
	event := new(StakeHubRewardDistributeFailed)
	if err := _StakeHub.contract.UnpackLog(event, "RewardDistributeFailed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubRewardDistributedIterator is returned from FilterRewardDistributed and is used to iterate over the raw logs and unpacked data for RewardDistributed events raised by the StakeHub contract.
type StakeHubRewardDistributedIterator struct {
	Event *StakeHubRewardDistributed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubRewardDistributedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubRewardDistributed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubRewardDistributed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubRewardDistributedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubRewardDistributedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubRewardDistributed represents a RewardDistributed event raised by the StakeHub contract.
type StakeHubRewardDistributed struct {
	OperatorAddress common.Address
	Reward          *big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterRewardDistributed is a free log retrieval operation binding the contract event 0xe34918ff1c7084970068b53fd71ad6d8b04e9f15d3886cbf006443e6cdc52ea6.
//
// Solidity: event RewardDistributed(address indexed operatorAddress, uint256 reward)
func (_StakeHub *StakeHubFilterer) FilterRewardDistributed(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubRewardDistributedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "RewardDistributed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubRewardDistributedIterator{contract: _StakeHub.contract, event: "RewardDistributed", logs: logs, sub: sub}, nil
}

// WatchRewardDistributed is a free log subscription operation binding the contract event 0xe34918ff1c7084970068b53fd71ad6d8b04e9f15d3886cbf006443e6cdc52ea6.
//
// Solidity: event RewardDistributed(address indexed operatorAddress, uint256 reward)
func (_StakeHub *StakeHubFilterer) WatchRewardDistributed(opts *bind.WatchOpts, sink chan<- *StakeHubRewardDistributed, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "RewardDistributed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubRewardDistributed)
				if err := _StakeHub.contract.UnpackLog(event, "RewardDistributed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseRewardDistributed is a log parse operation binding the contract event 0xe34918ff1c7084970068b53fd71ad6d8b04e9f15d3886cbf006443e6cdc52ea6.
//
// Solidity: event RewardDistributed(address indexed operatorAddress, uint256 reward)
func (_StakeHub *StakeHubFilterer) ParseRewardDistributed(log types.Log) (*StakeHubRewardDistributed, error) {
	event := new(StakeHubRewardDistributed)
	if err := _StakeHub.contract.UnpackLog(event, "RewardDistributed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubUndelegatedIterator is returned from FilterUndelegated and is used to iterate over the raw logs and unpacked data for Undelegated events raised by the StakeHub contract.
type StakeHubUndelegatedIterator struct {
	Event *StakeHubUndelegated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubUndelegatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubUndelegated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubUndelegated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubUndelegatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubUndelegatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubUndelegated represents a Undelegated event raised by the StakeHub contract.
type StakeHubUndelegated struct {
	OperatorAddress common.Address
	Delegator       common.Address
	Shares          *big.Int
	BnbAmount       *big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterUndelegated is a free log retrieval operation binding the contract event 0x3aace7340547de7b9156593a7652dc07ee900cea3fd8f82cb6c9d38b40829802.
//
// Solidity: event Undelegated(address indexed operatorAddress, address indexed delegator, uint256 shares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) FilterUndelegated(opts *bind.FilterOpts, operatorAddress []common.Address, delegator []common.Address) (*StakeHubUndelegatedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "Undelegated", operatorAddressRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubUndelegatedIterator{contract: _StakeHub.contract, event: "Undelegated", logs: logs, sub: sub}, nil
}

// WatchUndelegated is a free log subscription operation binding the contract event 0x3aace7340547de7b9156593a7652dc07ee900cea3fd8f82cb6c9d38b40829802.
//
// Solidity: event Undelegated(address indexed operatorAddress, address indexed delegator, uint256 shares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) WatchUndelegated(opts *bind.WatchOpts, sink chan<- *StakeHubUndelegated, operatorAddress []common.Address, delegator []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var delegatorRule []interface{}
	for _, delegatorItem := range delegator {
		delegatorRule = append(delegatorRule, delegatorItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "Undelegated", operatorAddressRule, delegatorRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubUndelegated)
				if err := _StakeHub.contract.UnpackLog(event, "Undelegated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseUndelegated is a log parse operation binding the contract event 0x3aace7340547de7b9156593a7652dc07ee900cea3fd8f82cb6c9d38b40829802.
//
// Solidity: event Undelegated(address indexed operatorAddress, address indexed delegator, uint256 shares, uint256 bnbAmount)
func (_StakeHub *StakeHubFilterer) ParseUndelegated(log types.Log) (*StakeHubUndelegated, error) {
	event := new(StakeHubUndelegated)
	if err := _StakeHub.contract.UnpackLog(event, "Undelegated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubValidatorCreatedIterator is returned from FilterValidatorCreated and is used to iterate over the raw logs and unpacked data for ValidatorCreated events raised by the StakeHub contract.
type StakeHubValidatorCreatedIterator struct {
	Event *StakeHubValidatorCreated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubValidatorCreatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubValidatorCreated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubValidatorCreated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubValidatorCreatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubValidatorCreatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubValidatorCreated represents a ValidatorCreated event raised by the StakeHub contract.
type StakeHubValidatorCreated struct {
	ConsensusAddress common.Address
	OperatorAddress  common.Address
	CreditContract   common.Address
	VoteAddress      []byte
	Raw              types.Log // Blockchain specific contextual infos
}

// FilterValidatorCreated is a free log retrieval operation binding the contract event 0xaecd9fb95e79c75a3a1de93362c6be5fe6ab65770d8614be583884161cd8228d.
//
// Solidity: event ValidatorCreated(address indexed consensusAddress, address indexed operatorAddress, address indexed creditContract, bytes voteAddress)
func (_StakeHub *StakeHubFilterer) FilterValidatorCreated(opts *bind.FilterOpts, consensusAddress []common.Address, operatorAddress []common.Address, creditContract []common.Address) (*StakeHubValidatorCreatedIterator, error) {
	var consensusAddressRule []interface{}
	for _, consensusAddressItem := range consensusAddress {
		consensusAddressRule = append(consensusAddressRule, consensusAddressItem)
	}
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var creditContractRule []interface{}
	for _, creditContractItem := range creditContract {
		creditContractRule = append(creditContractRule, creditContractItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ValidatorCreated", consensusAddressRule, operatorAddressRule, creditContractRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubValidatorCreatedIterator{contract: _StakeHub.contract, event: "ValidatorCreated", logs: logs, sub: sub}, nil
}

// WatchValidatorCreated is a free log subscription operation binding the contract event 0xaecd9fb95e79c75a3a1de93362c6be5fe6ab65770d8614be583884161cd8228d.
//
// Solidity: event ValidatorCreated(address indexed consensusAddress, address indexed operatorAddress, address indexed creditContract, bytes voteAddress)
func (_StakeHub *StakeHubFilterer) WatchValidatorCreated(opts *bind.WatchOpts, sink chan<- *StakeHubValidatorCreated, consensusAddress []common.Address, operatorAddress []common.Address, creditContract []common.Address) (event.Subscription, error) {
	var consensusAddressRule []interface{}
	for _, consensusAddressItem := range consensusAddress {
		consensusAddressRule = append(consensusAddressRule, consensusAddressItem)
	}
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}
	var creditContractRule []interface{}
	for _, creditContractItem := range creditContract {
		creditContractRule = append(creditContractRule, creditContractItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ValidatorCreated", consensusAddressRule, operatorAddressRule, creditContractRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubValidatorCreated)
				if err := _StakeHub.contract.UnpackLog(event, "ValidatorCreated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseValidatorCreated is a log parse operation binding the contract event 0xaecd9fb95e79c75a3a1de93362c6be5fe6ab65770d8614be583884161cd8228d.
//
// Solidity: event ValidatorCreated(address indexed consensusAddress, address indexed operatorAddress, address indexed creditContract, bytes voteAddress)
func (_StakeHub *StakeHubFilterer) ParseValidatorCreated(log types.Log) (*StakeHubValidatorCreated, error) {
	event := new(StakeHubValidatorCreated)
	if err := _StakeHub.contract.UnpackLog(event, "ValidatorCreated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubValidatorEmptyJailedIterator is returned from FilterValidatorEmptyJailed and is used to iterate over the raw logs and unpacked data for ValidatorEmptyJailed events raised by the StakeHub contract.
type StakeHubValidatorEmptyJailedIterator struct {
	Event *StakeHubValidatorEmptyJailed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubValidatorEmptyJailedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubValidatorEmptyJailed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubValidatorEmptyJailed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubValidatorEmptyJailedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubValidatorEmptyJailedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubValidatorEmptyJailed represents a ValidatorEmptyJailed event raised by the StakeHub contract.
type StakeHubValidatorEmptyJailed struct {
	OperatorAddress common.Address
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterValidatorEmptyJailed is a free log retrieval operation binding the contract event 0x2afdc18061ac21cff7d9f11527ab9c8dec6fabd4edf6f894ed634bebd6a20d45.
//
// Solidity: event ValidatorEmptyJailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) FilterValidatorEmptyJailed(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubValidatorEmptyJailedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ValidatorEmptyJailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubValidatorEmptyJailedIterator{contract: _StakeHub.contract, event: "ValidatorEmptyJailed", logs: logs, sub: sub}, nil
}

// WatchValidatorEmptyJailed is a free log subscription operation binding the contract event 0x2afdc18061ac21cff7d9f11527ab9c8dec6fabd4edf6f894ed634bebd6a20d45.
//
// Solidity: event ValidatorEmptyJailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) WatchValidatorEmptyJailed(opts *bind.WatchOpts, sink chan<- *StakeHubValidatorEmptyJailed, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ValidatorEmptyJailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubValidatorEmptyJailed)
				if err := _StakeHub.contract.UnpackLog(event, "ValidatorEmptyJailed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseValidatorEmptyJailed is a log parse operation binding the contract event 0x2afdc18061ac21cff7d9f11527ab9c8dec6fabd4edf6f894ed634bebd6a20d45.
//
// Solidity: event ValidatorEmptyJailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) ParseValidatorEmptyJailed(log types.Log) (*StakeHubValidatorEmptyJailed, error) {
	event := new(StakeHubValidatorEmptyJailed)
	if err := _StakeHub.contract.UnpackLog(event, "ValidatorEmptyJailed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubValidatorJailedIterator is returned from FilterValidatorJailed and is used to iterate over the raw logs and unpacked data for ValidatorJailed events raised by the StakeHub contract.
type StakeHubValidatorJailedIterator struct {
	Event *StakeHubValidatorJailed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubValidatorJailedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubValidatorJailed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubValidatorJailed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubValidatorJailedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubValidatorJailedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubValidatorJailed represents a ValidatorJailed event raised by the StakeHub contract.
type StakeHubValidatorJailed struct {
	OperatorAddress common.Address
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterValidatorJailed is a free log retrieval operation binding the contract event 0x4905ac32602da3fb8b4b7b00c285e5fc4c6c2308cc908b4a1e4e9625a29c90a3.
//
// Solidity: event ValidatorJailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) FilterValidatorJailed(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubValidatorJailedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ValidatorJailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubValidatorJailedIterator{contract: _StakeHub.contract, event: "ValidatorJailed", logs: logs, sub: sub}, nil
}

// WatchValidatorJailed is a free log subscription operation binding the contract event 0x4905ac32602da3fb8b4b7b00c285e5fc4c6c2308cc908b4a1e4e9625a29c90a3.
//
// Solidity: event ValidatorJailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) WatchValidatorJailed(opts *bind.WatchOpts, sink chan<- *StakeHubValidatorJailed, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ValidatorJailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubValidatorJailed)
				if err := _StakeHub.contract.UnpackLog(event, "ValidatorJailed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseValidatorJailed is a log parse operation binding the contract event 0x4905ac32602da3fb8b4b7b00c285e5fc4c6c2308cc908b4a1e4e9625a29c90a3.
//
// Solidity: event ValidatorJailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) ParseValidatorJailed(log types.Log) (*StakeHubValidatorJailed, error) {
	event := new(StakeHubValidatorJailed)
	if err := _StakeHub.contract.UnpackLog(event, "ValidatorJailed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubValidatorSlashedIterator is returned from FilterValidatorSlashed and is used to iterate over the raw logs and unpacked data for ValidatorSlashed events raised by the StakeHub contract.
type StakeHubValidatorSlashedIterator struct {
	Event *StakeHubValidatorSlashed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubValidatorSlashedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubValidatorSlashed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubValidatorSlashed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubValidatorSlashedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubValidatorSlashedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubValidatorSlashed represents a ValidatorSlashed event raised by the StakeHub contract.
type StakeHubValidatorSlashed struct {
	OperatorAddress common.Address
	JailUntil       *big.Int
	SlashAmount     *big.Int
	SlashType       uint8
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterValidatorSlashed is a free log retrieval operation binding the contract event 0x6e9a2ee7aee95665e3a774a212eb11441b217e3e4656ab9563793094689aabb2.
//
// Solidity: event ValidatorSlashed(address indexed operatorAddress, uint256 jailUntil, uint256 slashAmount, uint8 slashType)
func (_StakeHub *StakeHubFilterer) FilterValidatorSlashed(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubValidatorSlashedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ValidatorSlashed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubValidatorSlashedIterator{contract: _StakeHub.contract, event: "ValidatorSlashed", logs: logs, sub: sub}, nil
}

// WatchValidatorSlashed is a free log subscription operation binding the contract event 0x6e9a2ee7aee95665e3a774a212eb11441b217e3e4656ab9563793094689aabb2.
//
// Solidity: event ValidatorSlashed(address indexed operatorAddress, uint256 jailUntil, uint256 slashAmount, uint8 slashType)
func (_StakeHub *StakeHubFilterer) WatchValidatorSlashed(opts *bind.WatchOpts, sink chan<- *StakeHubValidatorSlashed, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ValidatorSlashed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubValidatorSlashed)
				if err := _StakeHub.contract.UnpackLog(event, "ValidatorSlashed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseValidatorSlashed is a log parse operation binding the contract event 0x6e9a2ee7aee95665e3a774a212eb11441b217e3e4656ab9563793094689aabb2.
//
// Solidity: event ValidatorSlashed(address indexed operatorAddress, uint256 jailUntil, uint256 slashAmount, uint8 slashType)
func (_StakeHub *StakeHubFilterer) ParseValidatorSlashed(log types.Log) (*StakeHubValidatorSlashed, error) {
	event := new(StakeHubValidatorSlashed)
	if err := _StakeHub.contract.UnpackLog(event, "ValidatorSlashed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubValidatorUnjailedIterator is returned from FilterValidatorUnjailed and is used to iterate over the raw logs and unpacked data for ValidatorUnjailed events raised by the StakeHub contract.
type StakeHubValidatorUnjailedIterator struct {
	Event *StakeHubValidatorUnjailed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubValidatorUnjailedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubValidatorUnjailed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubValidatorUnjailed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubValidatorUnjailedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubValidatorUnjailedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubValidatorUnjailed represents a ValidatorUnjailed event raised by the StakeHub contract.
type StakeHubValidatorUnjailed struct {
	OperatorAddress common.Address
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterValidatorUnjailed is a free log retrieval operation binding the contract event 0x9390b453426557da5ebdc31f19a37753ca04addf656d32f35232211bb2af3f19.
//
// Solidity: event ValidatorUnjailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) FilterValidatorUnjailed(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubValidatorUnjailedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "ValidatorUnjailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubValidatorUnjailedIterator{contract: _StakeHub.contract, event: "ValidatorUnjailed", logs: logs, sub: sub}, nil
}

// WatchValidatorUnjailed is a free log subscription operation binding the contract event 0x9390b453426557da5ebdc31f19a37753ca04addf656d32f35232211bb2af3f19.
//
// Solidity: event ValidatorUnjailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) WatchValidatorUnjailed(opts *bind.WatchOpts, sink chan<- *StakeHubValidatorUnjailed, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "ValidatorUnjailed", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubValidatorUnjailed)
				if err := _StakeHub.contract.UnpackLog(event, "ValidatorUnjailed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseValidatorUnjailed is a log parse operation binding the contract event 0x9390b453426557da5ebdc31f19a37753ca04addf656d32f35232211bb2af3f19.
//
// Solidity: event ValidatorUnjailed(address indexed operatorAddress)
func (_StakeHub *StakeHubFilterer) ParseValidatorUnjailed(log types.Log) (*StakeHubValidatorUnjailed, error) {
	event := new(StakeHubValidatorUnjailed)
	if err := _StakeHub.contract.UnpackLog(event, "ValidatorUnjailed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakeHubVoteAddressEditedIterator is returned from FilterVoteAddressEdited and is used to iterate over the raw logs and unpacked data for VoteAddressEdited events raised by the StakeHub contract.
type StakeHubVoteAddressEditedIterator struct {
	Event *StakeHubVoteAddressEdited // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *StakeHubVoteAddressEditedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakeHubVoteAddressEdited)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(StakeHubVoteAddressEdited)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *StakeHubVoteAddressEditedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakeHubVoteAddressEditedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakeHubVoteAddressEdited represents a VoteAddressEdited event raised by the StakeHub contract.
type StakeHubVoteAddressEdited struct {
	OperatorAddress common.Address
	NewVoteAddress  []byte
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterVoteAddressEdited is a free log retrieval operation binding the contract event 0x783156582145bd0ff7924fae6953ba054cf1233eb60739a200ddb10de068ff0d.
//
// Solidity: event VoteAddressEdited(address indexed operatorAddress, bytes newVoteAddress)
func (_StakeHub *StakeHubFilterer) FilterVoteAddressEdited(opts *bind.FilterOpts, operatorAddress []common.Address) (*StakeHubVoteAddressEditedIterator, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.FilterLogs(opts, "VoteAddressEdited", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return &StakeHubVoteAddressEditedIterator{contract: _StakeHub.contract, event: "VoteAddressEdited", logs: logs, sub: sub}, nil
}

// WatchVoteAddressEdited is a free log subscription operation binding the contract event 0x783156582145bd0ff7924fae6953ba054cf1233eb60739a200ddb10de068ff0d.
//
// Solidity: event VoteAddressEdited(address indexed operatorAddress, bytes newVoteAddress)
func (_StakeHub *StakeHubFilterer) WatchVoteAddressEdited(opts *bind.WatchOpts, sink chan<- *StakeHubVoteAddressEdited, operatorAddress []common.Address) (event.Subscription, error) {
	var operatorAddressRule []interface{}
	for _, operatorAddressItem := range operatorAddress {
		operatorAddressRule = append(operatorAddressRule, operatorAddressItem)
	}

	logs, sub, err := _StakeHub.contract.WatchLogs(opts, "VoteAddressEdited", operatorAddressRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakeHubVoteAddressEdited)
				if err := _StakeHub.contract.UnpackLog(event, "VoteAddressEdited", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseVoteAddressEdited is a log parse operation binding the contract event 0x783156582145bd0ff7924fae6953ba054cf1233eb60739a200ddb10de068ff0d.
//
// Solidity: event VoteAddressEdited(address indexed operatorAddress, bytes newVoteAddress)
func (_StakeHub *StakeHubFilterer) ParseVoteAddressEdited(log types.Log) (*StakeHubVoteAddressEdited, error) {
	event := new(StakeHubVoteAddressEdited)
	if err := _StakeHub.contract.UnpackLog(event, "VoteAddressEdited", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
