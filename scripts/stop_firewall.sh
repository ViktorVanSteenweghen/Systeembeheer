#!/bin/bash
iptables -F
ip6tables -F

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/tcp_syncookies
