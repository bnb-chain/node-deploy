#!/usr/bin/env bash

# Exit script on error
set -e


basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env

stateScheme="hash"
syncmode="full"
gcmode="full"
index=0
extraflags=""

src=${workspace}/.local/bsc/node0
if [ ! -d "$src" ] ;then
	echo "you must startup validator firstly..."
	exit 1
fi

if [ ! -z "$2" ] ;then
	index=$2
fi

if [ ! -z "$3" ] ;then
	syncmode=$3
fi

if [ ! -z "$4" ] ;then
	extraflags=$4
fi

node=node$index
dst=${workspace}/.local/bsc/fullnode/${node}
hardforkfile=${workspace}/.local/bsc/hardforkTime.txt
rialtoHash=`cat $src/init.log|grep "database=lightchaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`
BohrHardforkTime=`cat $hardforkfile | grep hardforkTime | awk -F" " '{print $NF}'`

mkdir -pv $dst/

function init() {
  cp $src/config.toml $dst/ && cp $src/genesis.json $dst/
  ${workspace}/bin/geth init --state.scheme ${stateScheme} --datadir ${dst}/ ${dst}/genesis.json
}

function start() {
  nohup ${workspace}/bin/geth --config $dst/config.toml --port $(( 31000 + $index ))  \
  --datadir $dst --rpc.allow-unprotected-txs --allow-insecure-unlock \
  --ws.addr 0.0.0.0 --ws.port $(( 8600 + $index )) --http.addr 0.0.0.0 --http.port $(( 8600 + $index )) --http.corsdomain "*" \
  --metrics --metrics.addr 0.0.0.0 --metrics.port $(( 6100 + $index )) --metrics.expensive \
  --gcmode $gcmode --syncmode $syncmode --state.scheme ${stateScheme} $extraflags \
  --rialtohash ${rialtoHash} --override.bohr ${BohrHardforkTime} \
  --override.immutabilitythreshold ${FullImmutabilityThreshold} --override.breatheblockinterval ${BreatheBlockInterval} \
  --override.minforblobrequest ${MinBlocksForBlobRequests} --override.defaultextrareserve ${DefaultExtraReserveForBlobRequests} \
  > $dst/bsc-node.log 2>&1 &
  echo $! > $dst/pid
}

function pruneblock() {
  ${workspace}/bin/geth snapshot prune-block --datadir $dst --datadir.ancient $dst/geth/chaindata/ancient/chain
}

function stop() {
  if [ ! -f "$dst/pid" ];then
    echo "$dst/pid not exist"
  else
    kill `cat $dst/pid`
    rm -f $dst/pid
    sleep 5
  fi
}

function clean() {
  stop
  rm -rf $dst/*
}

CMD=$1
case ${CMD} in
start)
    echo "===== start ===="
    clean
    init
    start
    echo "===== end ===="
    ;;
stop)
    echo "===== stop ===="
    stop
    echo "===== end ===="
    ;;
restart)
    echo "===== restart ===="
    stop
    start
    echo "===== end ===="
    ;;
clean)
    echo "===== clean ===="
    clean
    echo "===== end ===="
    ;;
pruneblock)
    echo "===== pruneblock ===="
    stop
    pruneblock
    echo "===== end ===="
    ;;
*)
    echo "Usage: start_fullnode.sh start|stop|restart|clean nodeIndex syncmode"
    echo "like: start_fullnode.sh start 1 snap, it will startup a snapsync node1"
    ;;
esac