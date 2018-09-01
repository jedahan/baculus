#!/bin/bash
set -ex

require false build-essential
require git
test -d /home/pi/cjdns || sudo -u pi git clone https://github.com/cjdelisle/cjdns.git "$_"
pushd /home/pi/cjdns
sudo -u pi git pull origin master
sudo -u pi git checkout 77259a49e5bc7ca7bc6dca5bd423e02be563bdc5
sudo -u pi NO_TEST=1 Seccomp_NO=1 ./do
cp cjdroute /usr/bin/
cjdroute --genconf | sed -e 's/"bind": "all"/"bind": "eth0"/' > /etc/cjdroute.conf
cp contrib/systemd/cjdns* /etc/systemd/system/
