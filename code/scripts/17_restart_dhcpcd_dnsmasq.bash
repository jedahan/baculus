#!/bin/bash
set -ex

sudo systemctl restart dhcpcd
sudo systemctl restart dnsmasq