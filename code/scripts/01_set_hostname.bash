#!/bin/bash
set -ex

test "$HOSTNAME" || exit -1
CURRENT_HOSTNAME=$(cat /etc/hostname | tr -d " \t\n\r")
test $CURRENT_HOSTNAME = $HOSTNAME && return 0
echo $HOSTNAME | sudo tee /etc/hostname
sudo sed -i "s/127.0.0.1.*$CURRENT_HOSTNAME/127.0.0.1\t$HOSTNAME/g" /etc/hosts
sudo hostname $HOSTNAME
