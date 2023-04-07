#!/bin/bash

# Feel free to use and modify this script, but please give credit to
# https://github.com/gaia/tezos-monitoring/

# You need to install JQ: https://stedolan.github.io/jq/

# Options
# Use "headers" to print out what each column means
# Use "status" to get a simple node is behind or up to date output, without numbers.
# This is useful when you only want to be alerted if your node falls behind by 10 or more blocks.
# Anything less than 10 blocks could be a false alarm

# Enter your path to tezos-client here, without a trailing slash
tc="/home/tezos/tezos/tezos-client"

# Enter the name of your tezos user here
tezosuser="tezos"

# This gives you cleaner output. Comment it out then log off/log in to see the warning.
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# Do not modify anything from here down

flag=$1
nodestatus=$(ps -fU $tezosuser | grep "octez-node run")
echo "$nodestatus" | grep -qi "octez-node run"
if [ $? -eq 0 ];then
        if [[ $flag = "headers" ]];then
                echo -e "DATE      |TIME    |NETWORK|NODE   |BEHIND"
        fi
        network1=$(curl -s "https://api.tzstats.com/explorer/tip" | jq -r '.status.blocks')
        network2=$(curl -s "https://api.tzkt.io/v1/head" | jq '.level')
        [ $network1 -gt $network2 ] && network=$network1 || network=$network2
        node=$($tc rpc get /chains/main/blocks/head | jq '.header.level')
        behind=$(( ${network}-${node} ))
        if [[ $flag = "status" ]];then
                if [[ $behind -gt 10 ]]; then
                        echo "Node is behind"
                else
                        echo "Node up to date"
                fi
        else
                echo -e "$(date "+%Y-%m-%d|%H:%M:%S")|\c"
                echo -e "$network|\c"
                echo -e "$node|\c"
                echo "$behind"
        fi
elif [[ -n "$flag" ]];then
        echo "Node Stopped"
fi
