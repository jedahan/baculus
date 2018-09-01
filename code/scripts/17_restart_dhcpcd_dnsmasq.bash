#!/bin/bash
set -ex

systemctl restart dhcpcd
systemctl restart dnsmasq
