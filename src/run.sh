#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# mpchain APIのcreate_sendを実行する【curl】
# CreatedAt: 2022-10-01
#---------------------------------------------------------------------------
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
