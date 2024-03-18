#!/usr/bin/env bash
basedir=$(cd `dirname $0`; pwd)
workspace=${basedir}
source ${workspace}/.env

stateScheme="hash"
syncmode="full"
gcmode="full"
index=0

src=${workspace}/.local/bsc/clusterNetwork/node0
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

node=node$index
dst=${workspace}/.local/bsc/fullnode/${node}
hardforkfile=${workspace}/.local/bsc/hardforkTime.txt
rialtoHash=`cat $src/init.log|grep "database=lightchaindata"|awk -F"=" '{print $NF}'|awk -F'"' '{print $1}'`
FeynmanHardforkTime=`cat $hardforkfile | grep hardforkTime | awk -F" " '{print $NF}'`
CancunHardforkTime=`expr ${FeynmanHardforkTime} + 10`

mkdir -pv $dst/

function start() {
  cp $src/config.toml $dst/ && cp $src/genesis.json $dst/
  ${workspace}/bin/geth init --state.scheme ${stateScheme} --datadir ${dst}/ ${dst}/genesis.json
  nohup ${workspace}/bin/geth --config $dst/config.toml --port $(( 31000 + $index ))  \
  --datadir $dst --rpc.allow-unprotected-txs --allow-insecure-unlock \
  --ws.addr 0.0.0.0 --ws.port $(( 8600 + $index )) --http.addr 0.0.0.0 --http.port $(( 8600 + $index )) --http.corsdomain "*" \
  --metrics --metrics.addr 0.0.0.0 --metrics.port $(( 6100 + $index )) --metrics.expensive \
  --gcmode $gcmode --syncmode $syncmode --state.scheme ${stateScheme} \
  --rialtohash ${rialtoHash} --override.feynman ${FeynmanHardforkTime} --override.cancun ${CancunHardforkTime} > $dst/bsc-node.log 2>&1 &
  echo $! > $dst/pid
}

function stop() {
  if [ ! -f "$dst/pid" ];then
    echo "$dst/pid not exist"
  else
    kill `cat $dst/pid`
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
    start
    echo "===== end ===="
    ;;
stop)
    echo "===== stop ===="
    stop
    echo "===== end ===="
    ;;
clean)
    echo "===== clean ===="
    clean
    echo "===== end ===="
    ;;
clean)
    echo "===== clean ===="
    clean
    ;;
*)
    echo "Usage: run_fullnode.sh start|stop|clean nodeIndex syncmode"
    echo "like: run_fullnode.sh start 1 snap, it will startup a snapsync node1"
    ;;
esac