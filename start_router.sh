#!/bin/bash
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -s 192.168.144.0/24 -d 192.168.146.0/24 -p tcp --dport 6379 -j DROP
tail -f /dev/null