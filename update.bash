#!/bin/bash
# baculus update script
HOME=/home/pi
LOG=$HOME/baculus_update.log

configure_wlan_interface() {
  grep 192.166.42.1 /etc/network/interfaces && return
  echo "configuring wlan0 interface" >> $LOG
    sudo bash -c 'cat << EOF >> /etc/network/interfaces
allow-hotplug wlan0

iface wlan0 inet static
  address 192.166.42.1
  netmask 255.255.255.0
EOF'
  echo "configured wlan0 interface" >> $LOG
}

configure_nginx() {
  test -f /etc/nginx/sites-available/baculus && return
  echo "configuring nginx" >> $LOG
  sudo bash -c 'cat << EOF > /etc/nginx/sites-available
server {
    listen 80;
    server_name baculus.mesh;

    # For iOS
    if ($http_user_agent ~* (CaptiveNetworkSupport) ) {
        return 302 http://baculus.mesh/;
    }

    # Android
    location /generate_204 {
        return 302 http://baculus.mesh/;
    }

    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:9191;
    }
}
EOF'
  sudo ln -s /etc/nginx/sites-available/baculus /etc/nginx/sites-enabled/baculus
  sudo systemctl enable nginx
  echo "configured nginx" >> $LOG
}

configure_hostapd() {
test -f /etc/hostapd.conf && return
echo "configuring hostapd" >> $LOG
  sudo bash -c 'cat << EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=baculus
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=baculusbuoy
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF'
echo "configured hostapd" >> $LOG
}

configure_dnsmasq() {
grep 192.166.4.2 /etc/dnsmasq.conf && return
echo "configuring dnsmasq" >> $LOG
sudo bash -c 'cat << EOF >> /etc/dnsmasq.conf
# Delays sending DHCPOFFER and proxydhcp replies for at least the specified number of seconds.
dhcp-mac=set:client_is_a_pi,B8:27:EB:*:*:*
dhcp-reply-delay=tag:client_is_a_pi,2

interface=wlan0
listen-address=127.0.0.1
listen-address=192.166.42.1
bind-interfaces
server=/mesh/192.166.42.1
local=/mesh/
domain=mesh
bogus-priv
dhcp-range=192.166.42.2,192.166.42.200,255.255.255.0,2h
address=/mesh/192.166.42.1
server=/#/1.1.1.1
dhcp-option=6,192.166.42.1
dhcp-authoritative
EOF'
echo "configured dnsmasq" >> $LOG
}

update_rclocal() {
  grep IPV6 /etc/rc.local && return
  echo "updating rc.local" >> $LOG
  sudo bash -c 'cat << EOF > /etc/rc.local
# Print ipv6 address
_IPV6=$(ip -6 address show dev eth0 scope link | awk "/inet6/{print \$2}")
if [ "$_IPV6" ]; then
  printf "Local ipv6 address is %s\n" "$_IPV6"
fi
  EOF'
  echo "updated rc.local" >> $LOG
}

install_mvd() {
  cd $HOME || return
  test -d mvd && test -f mvd/installed && return
  echo "installing mvd" >> $LOG
  git clone https://github.com/evbogue/mvd
  cd mvd || return
  git pull
  git checkout e98922f687ca57e6561d20a7b20423e50317ced2
  npm install
  touch installed
  echo "installed mvd" >> $LOG
}

install_scuttlebot() {
  cd $HOME || return
  test -d scuttlebot && test -f scuttlebot/installed && return
  echo "installing scuttlebot" >> $LOG
  git clone https://github.com/ssbc/scuttlebot.git
  cd scuttlebot || return
  git pull
  git checkout f11eacb2457ed757f2b267720f56e33fd206c42f
  npm install
  touch installed
  echo "installed scuttlebot" >> $LOG
}

install_cjdns() {
  cd $HOME || return
  test -d cjdns && test -f cjdns/installed && return
  echo "installing cjdns" >> $LOG
  git clone https://github.com/cjdelisle/cjdns.git
  cd cjdns || return
  git pull
  git checkout e98922f687ca57e6561d20a7b20423e50317ced2
  NO_TEST=1 Seccomp_NO=1 ./do
  ./cjdroute --genconf > cjdroute.conf
  sudo cp cjdroute /usr/bin/cjdroute
  sudo cp cjdroute.conf /etc/cjdroute.conf
  sudo sed -ie 's/"bind": "all"/"bind": "eth0"/' /etc/cjdroute.conf
  sudo cp contrib/systemd/cjdns* /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable cjdns
  sudo systemctl start cjdns
  touch installed
  echo "installed cjdns" >> $LOG
}

echo "--- START" >> $LOG
date >> $LOG
cd $HOME || return
install_mvd
install_scuttlebot
install_cjdns
update_rclocal
configure_hostapd
configure_dnsmasq
configure_nginx
configure_wlan_interface
date >> $LOG
echo "--- END" >> $LOG
