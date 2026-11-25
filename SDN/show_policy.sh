#!/bin/bash

echo "Current SDN Policies"

ovs-ofctl -O OpenFlow13 dump-flows br0