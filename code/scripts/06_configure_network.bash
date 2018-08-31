#!/bin/bash

test "$HOSTNAME" = 'baculusA' && suffix=10
test "$HOSTNAME" = 'baculusB' && suffix=11
test "$HOSTNAME" = 'baculusC' && suffix=12
test "$suffix" || suffix=5

sed -e "s/SUFFIX/$suffix/" /etc/dhcpcd.conf.template | sudo tee /etc/dhcpcd.conf