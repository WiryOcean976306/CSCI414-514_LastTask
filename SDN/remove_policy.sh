#!/bin/bash

echo "Removing all SDN policies..."

ovs-ofctl -O OpenFlow13 del-flows br0

ovs-ofctl -O OpenFlow13 dump-flows br0