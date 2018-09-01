#!/bin/bash
set -ex

require git
require npm nodejs
test -d /home/pi/mvd || sudo -u pi git clone https://github.com/jedahan/mvd --branch routerless "$_"
pushd "$_"
sudo -u pi npm install
sudo -u pi npm run build
popd # mvd
export ssb_appname=bac
grep "^ssb_appname=$ssb_appname\$" /etc/environment >/dev/null || {
    echo "ssb_appname=$ssb_appname" >> /etc/environment
}

ssb_host=$(grep -oE '10.0.17.[0-9]{1,3}' /etc/dhcpcd.conf | tr '\n' '\0')
export ssb_host
grep "^ssb_host=$ssb_host\$" /etc/environment >/dev/null || {
    echo "ssb_host=$ssb_host" >> /etc/environment
}

test -f /etc/systemd/system/mvd.service || {
    sed -e "s/__SSB_HOST__/$ssb_host/" /etc/systemd/system/mvd.service.template > /etc/systemd/system/mvd.service
}

systemctl daemon-reload
systemctl enable mvd
systemctl restart mvd
