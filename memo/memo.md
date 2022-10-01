mpchain APIのcreate_sendを実行する【curl】

　送金額や手数料をセットして試せるCLIを書いた。

<!-- more -->

# ブツ

* [リポジトリ][]

[リポジトリ]:https://github.com/ytyaru/Shell.curl.mpchain.CreateSend.20221001180946

# 実行

```sh
NAME='Shell.curl.mpchain.CreateSend.20221001180946'
git clone https://github.com/ytyaru/$NAME
cd $NAME/src
./run.sh
```

# 結果

```javascript
{"id":0,"jsonrpc":"2.0","result":{"btc_change":101556960,"btc_fee":2250,"btc_in":112970610,"btc_out":11411400,"tx_hex":"0100000001737a59194d5705b49f8e7c262d97d5cfd1e31ba5f6a7590402634bcbd71c53e9010000001976a91445fc13c9d3a0df34008291492c39e0efcdd220b888acffffffff02c81fae00000000001976a91445fc13c9d3a0df34008291492c39e0efcdd220b888ace0a20d06000000001976a91445fc13c9d3a0df34008291492c39e0efcdd220b888ac00000000"}}
```

# ソースコード

　抜粋。[mpchain API][]で[counterParty API][]の[create_send][]を実行する。

```sh
URL=https://mpchain.info/api/cb/
FROM=MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
TO=MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
QUANTITY=11411400
FEE_PER_KB=$((10 * 1000))
PARAMS='{"method":"create_send", "params":{"source":"'$FROM'","destination":"'$TO'","asset":"MONA","quantity":'$QUANTITY',"memo":null,"memo_is_hex":"no","fee_per_kb":'$FEE_PER_KB',"allow_unconfirmed_inputs":true,"extended_tx_info":true,"disable_utxo_locks":true}}'
JSON='{"id":0,"jsonrpc":"2.0","method":"proxy_to_counterpartyd","params":'$PARAMS'}'
curl -X POST -H "Content-Type: application/json" -d "$JSON" $URL
```

　[Mpurse][]のコードを解析して作った。

　宛先や送金額などを引数で受け取れるようにしたのが以下。

```sh
#!/usr/bin/env bash
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	[ -f 'error.sh' ] && . error.sh
	URL=https://mpchain.info/api/cb/
	SRC=MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
	DST=MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
	QUANTITY=11411400
	FEE_PER_KB=$((10 * 1000))
	ParseCommand() {
		THIS_NAME=`basename "$BASH_SOURCE"`
		SUMMARY='mpchain APIのcreate_sendを実行する'
		VERSION=0.0.1
		ARG_FLAG=; ARG_OPT=;
		Help() { eval "echo -e \"$(cat help.txt)\""; }
		Version() { echo "$VERSION"; }
		while getopts ":hvs:d:q:f:" OPT; do
		case $OPT in
			h) Help; exit 0;;
			v) Version; exit 0;;
			s) SRC="$OPTARG"; exit 0;;
			d) DST="$OPTARG"; ;;
			q) QUANTITY="$OPTARG"; ;;
			f) FEE_PER_KB="$OPTARG"; ;;
		esac
		done
		shift $(($OPTIND - 1))
	}
	ParseCommand "$@"
	CheckParams() {
		IsInt() { test 0 -eq $1 > /dev/null 2>&1 || expr $1 + 0 > /dev/null 2>&1; }
		IsInt "$QUANTITY" || Error '-q は 整数値をセットしてください。'
		IsInt "$FEE_PER_KB" || Error '-f は 整数値をセットしてください。'
	}
	CheckParams
	PARAMS='{"method":"create_send", "params":{"source":"'$SRC'","destination":"'$DST'","asset":"MONA","quantity":'$QUANTITY',"memo":null,"memo_is_hex":"no","fee_per_kb":'$FEE_PER_KB',"allow_unconfirmed_inputs":true,"extended_tx_info":true,"disable_utxo_locks":true}}'
	JSON='{"id":0,"jsonrpc":"2.0","method":"proxy_to_counterpartyd","params":'$PARAMS'}'
	curl -X POST -H "Content-Type: application/json" -d "$JSON" $URL
}
Run "$@"
```

キー|初期値|意味
----|------|----
`-s`|`MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu`|支払者アドレス
`-d`|`MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu`|受取者アドレス
`-q`|`11411400`|支払額（整数値 * 10⁻⁸ MONA）
`-f`|`10`|手数料（1KBあたり）

```sh
./run.sh -s 支払アドレス -d 宛先アドレス -q 支払額 -f 手数料
```

## 実行結果`Destination output is dust.`エラーについて

　支払額が少ないと`Destination output is dust`エラーになる。

```javascript
{"error":{"code":-32000,"data":{"args":["{\"code\": -32001, \"message\": \"Error composing send transaction via API: Destination output is dust.\"}"],"message":"{\"code\": -32001, \"message\": \"Error composing send transaction via API: Destination output is dust.\"}","type":"Exception"},"message":"Server error"},"id":0,"jsonrpc":"2.0"}
```

　適当に試してみたら`-q 54500`でエラーになった。`55000`だとOK。つまり大体`55000`（0.00055000 MONA）以上しか送金できないことになる。（2022-10-01時点）

　最低額の`1`(`0.00000001 MONA`)などは送れないらしい。この制限はモナコイン全体なのか、[mpchain API][]限定なのか。あるいは抜け道があるのか。

# 所感

　次はこれを以下の環境でそれぞれ実行できる形にしたい。

* WEBクライアント（JavaScript）
* ローカル（Node.js）

