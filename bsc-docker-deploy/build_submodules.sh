mkdir -p bin

# build bsc
cd bsc && make geth
go build -o ./build/bin/bootnode ./cmd/bootnode

cp ./build/bin/geth ../bin/geth
cp ./build/bin/bootnode ../bin/bootnode

cd ..
cd node && make build
cp ./build/tbnbcli ../bin/tbnbcli
cp ./build/bnbchaind ../bin/bnbchaind

cd ..
cd bsc-genesis-contract
npm install
