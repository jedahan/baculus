#!/bin/bash
set -ex

# This forces all dns queries to go to our dnsmasq
systemctl list-unit-files iptables-restore.service | grep enabled && return
iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -i eth0 -j DNAT --to-destination 10.0.42.1:53
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -i eth0 -j DNAT --to-destination 10.0.42.1:53
iptables-save > /etc/iptables.dns.nat
systemctl daemon-reload
systemctl enable iptables-restore
