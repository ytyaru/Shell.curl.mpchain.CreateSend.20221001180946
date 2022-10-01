#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# mpchain APIのcreate_sendを実行する【curl】
# CreatedAt: 2022-10-01
#---------------------------------------------------------------------------
URL=https://mpchain.info/api/cb/
FROM=MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
TO=MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
QUANTITY=11411400
FEE_PER_KB=$((10 * 1000))
PARAMS='{"method":"create_send", "params":{"source":"'$FROM'","destination":"'$TO'","asset":"MONA","quantity":'$QUANTITY',"memo":null,"memo_is_hex":"no","fee_per_kb":'$FEE_PER_KB',"allow_unconfirmed_inputs":true,"extended_tx_info":true,"disable_utxo_locks":true}}'
JSON='{"id":0,"jsonrpc":"2.0","method":"proxy_to_counterpartyd","params":'$PARAMS'}'
curl -X POST -H "Content-Type: application/json" -d "$JSON" $URL

