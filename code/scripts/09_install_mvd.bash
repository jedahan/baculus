#!/bin/bash
set -ex

require git
require npm nodejs
test -d ~/mvd || git clone https://github.com/jedahan/mvd --branch routerless "$_"
pushd "$_"
npm install
npm run build
popd # mvd
export ssb_appname=bac
grep "^ssb_appname=$ssb_appname\$" /etc/environment >/dev/null || {
    echo "ssb_appname=$ssb_appname" | sudo tee -a /etc/environment
}

ssb_host=$(grep -oE '10.0.17.[0-9]{1,3}' /etc/dhcpcd.conf)
export ssb_host
grep "^ssb_host=$ssb_host\$" /etc/environment >/dev/null || {
    echo "ssb_host=$ssb_host" | sudo tee -a /etc/environment
}

test -f /etc/systemd/system/mvd.service || {
    sed -e "s/__SSB_HOST__/$ssb_host/" /etc/systemd/system/mvd.service.template | sudo tee /etc/systemd/system/mvd.service
}
sudo systemctl daemon-reload
sudo systemctl enable mvd
sudo systemctl restart mvd