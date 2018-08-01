#!/bin/bash
# baculus update script
HOME=/home/pi
LOG=$HOME/baculus.log
export src=$HOME/config/ && mkdir -p $src

configure_wlan_interface() {
  grep "configured wlan interface" $LOG && return
  echo "configuring wlan interface" >> $LOG
  printf '
allow-hotplug wlan0

iface wlan0 inet static
  address 10.0.42.1
  netmask 255.255.255.0
' | sudo tee -a /etc/network/interfaces
  echo "configured wlan interface" >> $LOG
}

configure_nginx() {
  grep "configured nginx" $LOG && return
  echo "configuring nginx" >> $LOG
  sudo bash -c 'cat << EOF > /etc/nginx/sites-available/baculus
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
        proxy_pass         http://127.0.0.1:8027;
    }
}
EOF'
  sudo ln -s /etc/nginx/sites-available/baculus /etc/nginx/sites-enabled/baculus
  sudo rm /etc/nginx/sites-available/default
  sudo systemctl enable nginx
  echo "configured nginx" >> $LOG
}

configure_hostapd() {
  grep "configured hostapd" $LOG && return
  echo "configuring hostapd" >> $LOG
  local config=/etc/hostapd/hostapd.conf
  printf "interface=wlan0
driver=nl80211
ssid=%s
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
" "$HOSTNAME" | sudo tee $config
  echo "DAEMON_CONF=$config" | sudo tee -a /etc/default/hostapd
  echo "configured hostapd" >> $LOG
}

configure_hosts() {
  grep "configured hosts" $LOG && return
  echo "configuring hosts" >> $LOG
  local config=/etc/hosts
  printf "
127.0.0.1 baculus
10.0.42.1 baculus.mesh
" | sudo tee -a $config
  echo "configured hosts" >> $LOG
}

configure_dnsmasq() {
  grep "configured dnsmasq" $LOG && return
  echo "configuring dnsmasq" >> $LOG
printf \
"# Delays sending DHCPOFFER and proxydhcp replies for at least the specified number of seconds.
dhcp-mac=set:client_is_a_pi,B8:27:EB:*:*:*
dhcp-reply-delay=tag:client_is_a_pi,2

interface=wlan0
listen-address=127.0.0.1
listen-address=10.0.42.1
bind-interfaces
server=/mesh/10.0.42.1
local=/mesh/
domain=mesh
bogus-priv
dhcp-range=10.0.42.2,10.0.42.200,255.255.255.0,2h
address=/mesh/10.0.42.1
server=/#/1.1.1.1
dhcp-option=6,10.0.42.1
dhcp-authoritative
" | sudo tee /etc/dnsmasq.conf
  echo "configured dnsmasq" >> $LOG
}

update_rclocal() {
  grep "updated rclocal" $LOG && return
  echo "updating rclocal" >> $LOG
  printf "
# Print ipv6 address
_IPV6=\$(ip -6 address show dev eth0 scope link | awk '/inet6/{print \$2}')
if [ \"\$_IPV6\" ]; then
  printf 'Local ipv6 address is %s\\n' \"\$_IPV6\"
fi
" | sudo tee -a /etc/rc.local
  echo "updated rc.local" >> $LOG
}

install_mvd() {
  grep "installed mvd" $LOG && return
  echo "installing mvd" >> $LOG
  cd $HOME
  git clone https://github.com/evbogue/mvd
  pushd mvd
  git pull
  git checkout e98922f687ca57e6561d20a7b20423e50317ced2
  npm install
  popd
  echo "installed mvd" >> $LOG
}

install_scuttlebot() {
  grep "installed scuttlebot" $LOG && return
  echo "installing scuttlebot" >> $LOG
  cd $HOME
  # broadcast-stream
  git clone https://github.com/jedahan/broadcast-stream.git --branch routerless
  pushd broadcast-stream
  git checkout 53e28ee7be3a247a62dc6f7003d2c89b9a38770e
  npm install
  popd
  # scuttlebot
  git clone https://github.com/jedahan/scuttlebot.git --branch routerless
  pushd scuttlebot
  git checkout 4d1c0a97e7b1d5f216ec425190d77743bc28e15f
  npm install
  npm link ../broadcast-stream
  popd
  # appname
  echo ssb_appname=bac | sudo tee -a /etc/environment
  echo "installed scuttlebot" >> $LOG
}

install_cjdns() {
  grep "installed cjdns" $LOG && return
  echo "installing cjdns" >> $LOG
  cd $HOME
  git clone https://github.com/cjdelisle/cjdns.git
  pushd cjdns
  git pull
  git checkout e98922f687ca57e6561d20a7b20423e50317ced2
  NO_TEST=1 Seccomp_NO=1 ./do
  sudo cp cjdroute /usr/bin/cjdroute
  cjdroute --genconf | sed -e 's/"bind": "all"/"bind": "eth0"/' | sudo tee /etc/cjdroute.conf
  sudo cp contrib/systemd/cjdns* /etc/systemd/system/
  popd
  echo "installed cjdns" >> $LOG
}

wifi_host() {
  echo "setting wifi to host mode (removing from dhcpcd)" >> $LOG

  local config=/etc/dhcpcd.conf
  grep denyinterfaces $config || echo denyinterfaces wlan0 | sudo tee -a $config
  sudo sed -ie 's/^#denyinterfaces wlan0$/denyinterfaces wlan0' $config

  echo "set wifi to host mode (removed from dhcpcd)" >> $LOG
}

wifi_client() {
  echo "setting wifi to client mode (adding to dhcpcd)" >> $LOG

  local config=/etc/dhcpcd.conf
  grep denyinterfaces $config || echo denyinterfaces wlan0 | sudo tee -a $config
  sudo sed -ie 's/^denyinterfaces wlan0$/#denyinterfaces wlan0' $config

  echo "set wifi to client mode (added from dhcpcd)" >> $LOG
}

setup_npm() {
  export NPM_CONFIG_PREFIX=$HOME/.npm/global
  mkdir -p $NPM_CONFIG_PREFIX
  echo NPM_CONFIG_PREFIX=$NPM_CONFIG_PREFIX | sudo tee -a /etc/environment
}

echo "--- START" $(date) >> $LOG
cd $HOME || return
setup_npm
install_mvd
install_scuttlebot
install_cjdns
update_rclocal
configure_hostapd
configure_dnsmasq
configure_nginx
configure_wlan_interface
wifi_host
echo "--- END" $(date) >> $LOG
