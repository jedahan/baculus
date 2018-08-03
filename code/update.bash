#!/bin/bash
# baculus update script
set -ex
HOME=/home/pi
LOG=$HOME/baculus.log
export src=$HOME/config/ && mkdir -p $src

setup_npm() {
  export NPM_CONFIG_PREFIX=$HOME/.npm/global
  mkdir -p $NPM_CONFIG_PREFIX
  echo NPM_CONFIG_PREFIX=$NPM_CONFIG_PREFIX | sudo tee -a /etc/environment
  export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
}

install_tileserver() {
  npm install -g tileserver-gl-light
  wget https://baculus.co/de/tiles/2017-07-03_california_mountain-view.mbtiles
  wget https://baculus.co/de/tiles/2017-07-03_new-york_brooklyn.mbtiles
}

meshpoint() {
  local mesh_dev="${1:-wlan1}"
  local mesh_name="${2:-bacuhoc}"
  sudo ifconfig $mesh_dev down
  sudo iw $mesh_dev set type mp
  sudo ifconfig $mesh_dev up
  sudo iw dev $mesh_dev mesh join ${mesh_name} freq 2412 HT40+
  sudo iw dev $mesh_dev set mesh_param mesh_fwding=0
  sudo iw dev $mesh_dev set mesh_param mesh_rssi_threshold -65
}

adhoc() {
  local mesh_dev="${1:-wlan0}"
  local mesh_name="${2:-bacumesh}"

  sudo ifconfig $mesh_dev down
  sudo iw $mesh_dev set type ibss
  sudo ifconfig $mesh_dev up
  sudo iw dev $mesh_dev ibss join ${mesh_name} 2412 HT40+
}

configure_nginx() {
  grep "configured nginx" $LOG && return
  echo "configuring nginx" >> $LOG
  printf '
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
        proxy_set_header   Host $http_host;
        proxy_pass         http://127.0.0.1:8008;
    }

    location /map {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host $http_host;
        proxy_pass         http://127.0.0.1:8080;
    }
}
' | sudo tee /etc/nginx/sites-available/baculus
  sudo ln -s /etc/nginx/sites-available/baculus /etc/nginx/sites-enabled/baculus
  sudo rm /etc/nginx/sites-enabled/default
  sudo systemctl enable nginx
  echo "configured nginx" >> $LOG
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

install_scuttlebot() {
  grep "installed scuttlebot" $LOG && return
  echo "installing scuttlebot" >> $LOG
  cd $HOME
  # multiserver
  git clone https://github.com/jedahan/multiserver.git --branch routerless
  pushd multiserver
  git checkout 93e96755fc2dfe1cfa37386a92e4e9d87c3378bc
  npm install
  popd
  # broadcast-stream
  git clone https://github.com/jedahan/broadcast-stream.git --branch routerless
  pushd broadcast-stream
  git checkout 53e28ee7be3a247a62dc6f7003d2c89b9a38770e
  npm install
  popd
  # scuttlebot
  git clone https://github.com/jedahan/scuttlebot.git --branch routerless
  pushd scuttlebot
  git checkout 7ed0c946a833212406ee492f27a29ba239669d6f
  npm install
  npm link ../broadcast-stream
  npm link ../multiserver
  popd
  # appname
  echo ssb_appname=bac | sudo tee -a /etc/environment
  echo "installed scuttlebot" >> $LOG
}

install_mvd() {
  grep "installed mvd" $LOG && return
  echo "installing mvd" >> $LOG
  cd $HOME
  git clone https://github.com/jedahan/mvd --branch routerless
  pushd mvd
  git checkout d8a4a9ffc444a9daa612ede79049083a4ce1ca7c
  npm install
  npm link ../scuttlebot
  popd
  echo "installed mvd" >> $LOG
}

install_cjdns() {
  grep "installed cjdns" $LOG && return
  echo "installing cjdns" >> $LOG
  cd $HOME
  git clone https://github.com/cjdelisle/cjdns.git
  pushd cjdns
  git pull
  git checkout 77259a49e5bc7ca7bc6dca5bd423e02be563bdc5
  NO_TEST=1 Seccomp_NO=1 ./do
  sudo cp cjdroute /usr/bin/cjdroute
  cjdroute --genconf | sed -e 's/"bind": "all"/"bind": "eth0"/' | sudo tee /etc/cjdroute.conf
  sudo cp contrib/systemd/cjdns* /etc/systemd/system/
  popd
  echo "installed cjdns" >> $LOG
}

echo "--- START" $(date) >> $LOG
cd $HOME || return
setup_npm
install_cjdns
update_rclocal
configure_dnsmasq
configure_nginx
install_scuttlebot
install_mvd
install_tileserver
adhoc
echo "--- END" $(date) >> $LOG
