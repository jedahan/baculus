#!/bin/bash
set -ex

require false build-essential
require git
test -d ~/cjdns || git clone https://github.com/cjdelisle/cjdns.git "$_"
pushd ~/cjdns
git pull origin master
git checkout 77259a49e5bc7ca7bc6dca5bd423e02be563bdc5
NO_TEST=1 Seccomp_NO=1 ./do
sudo cp cjdroute /usr/bin/
cjdroute --genconf | sed -e 's/"bind": "all"/"bind": "eth0"/' | sudo tee /etc/cjdroute.conf
sudo cp contrib/systemd/cjdns* /etc/systemd/system/
