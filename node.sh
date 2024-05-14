#!/bin/bash

VALIDATOR="validator2"
CHAINID="volley_9981-9981"
#replace test to your moniker name
MONIKER="test"
MAINNODE_RPC="http://142.132.202.228:26657"
MAINNODE_ID="8f0b4fdb4dd205d8ec43f2f33582cb2e8da7eb4e@142.132.202.228:26656"
KEYRING="os"
CONFIG="$HOME/.v2xd/config/config.toml"
APPCONFIG="$HOME/.v2xd/config/app.toml"


# Set moniker and chain-id for chain (Moniker can be anything, chain-id must be same mainnode)
v2xd init $MONIKER --chain-id=$CHAINID

# Fetch genesis.json from genesis node
curl $MAINNODE_RPC/genesis? | jq ".result.genesis" > ~/.v2xd/config/genesis.json

v2xd validate-genesis

# set seed to main node's id manually
# sed -i 's/seeds = ""/seeds = "'$MAINNODE_ID'"/g' ~/.v2xd/config/config.toml

# add for rpc
sed -i 's/timeout_commit = "5s"/timeout_commit = "3s"/g' "$CONFIG"
sed -i 's/cors_allowed_origins = \[\]/cors_allowed_origins = \["*"\]/g' "$CONFIG"
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' "$CONFIG"
sed -i '/\[api\]/,+3 s/enable = false/enable = true/' "$APPCONFIG"
sed -i '/\[api\]/,+3 s/swagger = false/swagger = true/' "$APPCONFIG"
sed -i 's/enabled-unsafe-cors = false/enabled-unsafe-cors = true/g'  "$APPCONFIG"
sed -i 's/api = "eth,net,web3"/api = "eth,txpool,personal,net,debug,web3"/g' "$APPCONFIG"

# add account for validator in the node
v2xd keys add $VALIDATOR --keyring-backend $KEYRING

# run node
v2xd start --rpc.laddr tcp://0.0.0.0:26657 --pruning=nothing