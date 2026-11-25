#!/bin/bash

echo "================================="
echo " SDN Policy Controller"
echo "================================="

ovs-vsctl --may-exist add-br br0

ovs-vsctl set bridge br0 protocols=OpenFlow13

ovs-ofctl -O OpenFlow13 del-flows br0

echo ""
echo "Installing SDN Policies..."
echo ""

POLICY_FILE="/sdn/policy.json"

CLIENT_API=$(jq -r '.client_api' $POLICY_FILE)
API_REDIS=$(jq -r '.api_redis' $POLICY_FILE)
CLIENT_REDIS=$(jq -r '.client_redis' $POLICY_FILE)

if [ "$CLIENT_API" = "allow" ]
then
    echo "Policy: ALLOW Client -> API (TCP 8000)"

    ovs-ofctl -O OpenFlow13 add-flow br0 "priority=300,tcp,tp_dst=8000,actions=normal"
else
    echo "Policy: DENY Client -> API (TCP 8000)"

    ovs-ofctl -O OpenFlow13 add-flow br0 "priority=300,tcp,tp_dst=8000,actions=drop"
fi

if [ "$API_REDIS" = "allow" ]
then
    echo "Policy: ALLOW API -> Redis (TCP 6379)"

    ovs-ofctl -O OpenFlow13 add-flow br0 "priority=350,tcp,tp_dst=6379,actions=normal"
else
    echo "Policy: DENY API -> Redis (TCP 6379)"

    ovs-ofctl -O OpenFlow13 add-flow br0 "priority=350,tcp,tp_dst=6379,actions=drop"
fi

if [ "$CLIENT_REDIS" = "allow" ]
then
    echo "Policy: ALLOW Client -> Redis (TCP 6379)"

    ovs-ofctl -O OpenFlow13 add-flow br0 "priority=400,tcp,tp_dst=6379,actions=normal"
else
    echo "Policy: DENY Client -> Redis (TCP 6379)"

    ovs-ofctl -O OpenFlow13 add-flow br0 "priority=400,tcp,tp_dst=6379,actions=drop"
fi

echo "Policies Applied"

ovs-ofctl -O OpenFlow13 dump-flows br0