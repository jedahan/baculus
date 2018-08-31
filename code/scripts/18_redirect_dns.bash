#!/bin/bash
set -ex

# This forces all dns queries to go to our dnsmasq
sudo systemctl list-unit-files iptables-restore.service | grep enabled && return
sudo iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -i eth0 -j DNAT --to-destination 10.0.42.1:53
sudo iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -i eth0 -j DNAT --to-destination 10.0.42.1:53
sudo iptables-save | sudo tee /etc/iptables.dns.nat
sudo systemctl daemon-reload
sudo systemctl enable iptables-restore
