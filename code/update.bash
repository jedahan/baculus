#!/bin/bash
# baculus update script
set -ex
HOME=/home/pi
LOG=$HOME/log/baculus.log
INSTALL_LOG=$HOME/log/install.log

suffix() {
  test $HOSTNAME = 'baculusA' && echo -n 10 && return
  test $HOSTNAME = 'baculusB' && echo -n 11 && return
  test $HOSTNAME = 'baculusC' && echo -n 12 && return
  echo -n 5
}

redirect_dns() {
  sudo iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -i eth0 -j DNAT --to-destination 10.0.42.1:53
  sudo iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -i eth0 -j DNAT --to-destination 10.0.42.1:53
}

set_hostname() {
  test -f /boot/hostname || return 0
  CURRENT_HOSTNAME=$(cat /etc/hostname | tr -d " \t\n\r")
  NEW_HOSTNAME=$(cat /boot/hostname)
  test $CURRENT_HOSTNAME = $NEW_HOSTNAME && return 0
  echo $NEW_HOSTNAME | sudo tee /etc/hostname
  sudo sed -i "s/127.0.0.1.*$CURRENT_HOSTNAME/127.0.0.1\t$NEW_HOSTNAME/g" /etc/hosts
  sudo hostname $NEW_HOSTNAME
}

require() {
  local binary=${1}
  shift
  local packages=${*:-$binary}
  command -v "$binary" >/dev/null 2>&1 && return 0
  # normally you would quote $packages, but we want multiple package
  # install support (`ruby ruby-dev`, not `"ruby ruby-dev"`)
  sudo DEBIAN_FRONTEND=noninteractive apt install -y $packages
}

raspi_config() {
  test "$LANG" = 'en_US.UTF-8' || sudo raspi-config nonint do_change_locale "$_"
  sudo raspi-config nonint do_configure_keyboard us
  sudo raspi-config nonint do_wifi_country US
  sudo raspi-config nonint do_ssh 0

  # give minimal memory to gpu
  local SPLIT=16
  test -e /boot/arm${SPLIT}_start.elf && cmp /boot/arm${SPLIT}_start.elf /boot/start.elf >/dev/null 2>&1 && return 0
  sudo raspi-config nonint do_memory_split $SPLIT
}

configure_hosts() {
  grep "configured hosts" $INSTALL_LOG && return
  echo 'configuring hosts'
  local config=/etc/hosts
  grep baculus.mesh /etc/hosts >/dev/null && return
  printf "
127.0.0.1 baculus %s
10.0.42.1 baculus.mesh baculus.map baculus.chat
" "$HOSTNAME" | sudo tee -a $config
  echo 'configured hosts' >> $INSTALL_LOG
}

clone_source() {
  grep '^cloned source' $INSTALL_LOG && return
  echo 'cloning source'
  require git
  cd
  test -d baculus || git clone https://github.com/baculus-buoy/baculus.git
  echo 'cloned source' >> $INSTALL_LOG
}

install_npm() {
  export NPM_CONFIG_PREFIX=$HOME/npm
  mkdir -p $NPM_CONFIG_PREFIX
  grep NPM_CONFIG_PREFIX /etc/environment || {
    echo NPM_CONFIG_PREFIX=$NPM_CONFIG_PREFIX | sudo tee -a /etc/environment
  }
  export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
  grep PATH /etc/environment || {
    echo PATH="$PATH" | sudo tee -a /etc/environment
  }
  require npm nodejs
}

install_scuttlebot() {
  grep '^installed scuttlebot$' $INSTALL_LOG && return
  echo 'installing scuttlebot'
  require git
  require npm nodejs
  cd
  # multiserver
  test -d multiserver || git clone https://github.com/jedahan/multiserver.git --branch routerless
  pushd multiserver
  git checkout 93e96755fc2dfe1cfa37386a92e4e9d87c3378bc
  npm install
  popd # multiserver
  # broadcast-stream
  test -d broadcast-stream || git clone https://github.com/jedahan/broadcast-stream.git --branch routerless
  pushd broadcast-stream
  git checkout 53e28ee7be3a247a62dc6f7003d2c89b9a38770e
  npm install
  popd # broadcast-stream
  # scuttlebot
  test -d scuttlebot || git clone https://github.com/jedahan/scuttlebot.git --branch routerless
  pushd scuttlebot
  git checkout 7ed0c946a833212406ee492f27a29ba239669d6f
  npm install
  npm link ../broadcast-stream
  npm link ../multiserver
  popd # scuttlebot
  test -f /etc/systemd/system/scuttlebot.service || sudo cp $HOME/baculus/code/"$_" "$_"
  sudo systemctl daemon-reload
  # appname
  grep '^ssb_appname=bac$' /etc/environment >/dev/null || {
    echo 'ssb_appname=bac' | sudo tee -a /etc/environment
  }
  grep "^ssb_host=10.0.17.`suffix`\$" /etc/environment >/dev/null || {
    echo "ssb_host=10.0.17.`suffix`" | sudo tee -a /etc/environment
  }
  echo 'installed scuttlebot' >> $INSTALL_LOG
}

install_mvd() {
  grep '^installed mvd$' $INSTALL_LOG && return
  echo 'installing mvd'
  require git
  require npm nodejs
  cd
  test -d mvd || git clone https://github.com/jedahan/mvd --branch routerless
  pushd mvd
  git checkout c20241f95894c5cbe07bfb52c937ba588fd5e0e3
  npm install
  npm run build
  popd # mvd
  grep '^ssb_appname=bac$' /etc/environment >/dev/null || {
    echo 'ssb_appname=bac' | sudo tee -a /etc/environment
  }
  test -f /etc/systemd/system/mvd.service || sudo cp $HOME/baculus/code/"$_" "$_"
  sudo systemctl daemon-reload
  sudo systemctl enable mvd
  sudo systemctl restart mvd
  echo 'installed mvd' >> $INSTALL_LOG
}

install_tileserver() {
  grep '^installed tileserver$' $INSTALL_LOG && return
  echo 'installing tileserver'
  require false libcairo2-dev
  require false libprotobuf-dev
  require npm nodejs
  npm install -g tileserver-gl-light
  pushd $HOME/baculus/code
  cp home/pi/tileserver.json $HOME/
  cp -r home/pi/tiles $HOME/
  sudo cp etc/systemd/system/tileserver.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable tileserver
  sudo systemctl start tileserver
  popd # $HOME/baculus/code
  echo 'installed tileserver' >> $INSTALL_LOG
}

install_cjdns() {
  grep '^installed cjdns$' $INSTALL_LOG && return
  echo 'installing cjdns'
  require false build-essential
  require git
  cd
  test -d cjdns || git clone https://github.com/cjdelisle/cjdns.git
  pushd cjdns
  git pull origin master
  git checkout 77259a49e5bc7ca7bc6dca5bd423e02be563bdc5
  NO_TEST=1 Seccomp_NO=1 ./do
  sudo cp cjdroute /usr/bin/
  cjdroute --genconf | sed -e 's/"bind": "all"/"bind": "eth0"/' | sudo tee /etc/cjdroute.conf
  sudo cp contrib/systemd/cjdns* /etc/systemd/system/
  popd #cjdns
  echo 'installed cjdns' >> $INSTALL_LOG
}

configure_network() {
  grep '^configuring network' $INSTALL_LOG && return
  echo 'configured network'
  sed -e "s/SUFFIX/`suffix`/" $HOME/baculus/code/etc/dhcpcd.conf.template | sudo tee /etc/dhcpcd.conf
  echo 'configured network' >> $INSTALL_LOG
}

install_dnsmasq() {
  grep '^installed dnsmasq$' $INSTALL_LOG && return
  echo 'installing dnsmasq'
  require dnsmasq
  sudo cp $HOME/baculus/code/etc/dnsmasq.conf /etc/dnsmasq.conf
  echo 'installed dnsmasq' >> $INSTALL_LOG
}

install_nginx() {
  grep 'installing nginx' $INSTALL_LOG && return
  echo 'installed nginx'
  require nginx
  test -f /etc/nginx/sites-available/baculus || sudo cp $HOME/baculus/code/etc/nginx/sites-available/baculus "$_"
  test -f /etc/nginx/sites-enabled/baculus || sudo ln -s /etc/nginx/sites-available/baculus "$_"
  test -f /etc/nginx/sites-enabled/default && sudo rm "$_"
  sudo systemctl enable nginx
  echo 'installed nginx' >> $INSTALL_LOG
}

build_site() {
  grep '^built site$' $INSTALL_LOG && return
  echo 'building site'
  require gem ruby ruby-dev
  pushd baculus
  command -v bundle >/dev/null 2>&1 || sudo gem install bundler
  bundle install
  bundle exec jekyll build
  pushd _site
  sed -i -e 's/^.*oogle.*$//' ./*html* ./*/*html*
  popd # _site
  popd # baculus
  echo 'built site' >> $INSTALL_LOG
}

install_adhoc() {
  grep '^installed adhoc$' $INSTALL_LOG && return
  echo 'installing adhoc'
  sudo cp $HOME/baculus/code/etc/wpa_supplicant/wpa_supplicant-wlan1.conf /etc/wpa_supplicant/wpa_supplicant-wlan1.conf
  echo 'installed adhoc' >> $INSTALL_LOG
}

update_rclocal() {
  grep '^updated rclocal$' $INSTALL_LOG && return
  echo 'updating rclocal'
  printf '
# setup adhoc mode
/home/pi/adhoc.sh
ip addr
' | sudo tee -a /etc/rc.local
  echo 'updated rc.local' >> $INSTALL_LOG
}

enable_ssh() {
  test -f /boot/ssh || sudo touch "$_"
}

share_hostname() {
  test -f /boot/"${HOSTNAME}" || sudo touch "$_"
}

meshpoint() {
  test -f $HOME/meshpoint.sh || {
  echo 'installing meshpoint.sh'
    cp $HOME/baculus/code/home/pi/meshpoint.sh $HOME/meshpoint.sh
    echo 'installed meshpoint.sh'
  }
  bash $HOME/meshpoint.sh
}

install_utilities() {
  test -f $HOME/blink.sh || cp $HOME/baculus/code/home/pi/blink.sh $_
  require pinout python3-gpiozero
}

remove_eth0_route() {
  ip route show default dev eth0 | grep default || return 0
  sudo ip route del default dev eth0
}

install_mosh() {
  require mosh
}

restart_dhcpcd() {
  sudo systemctl restart dhcpcd
}

restart_dnsmasq() {
  sudo systemctl restart dnsmasq
}

cd
test -d "$(dirname $LOG)" || mkdir -p "$(dirname $LOG)"
touch $LOG || exit 1

{
  echo "--- START" "$(date)"
  set_hostname
  raspi_config
  configure_hosts
  remove_eth0_route
  install_mosh
  clone_source
  configure_network
  install_npm

  install_scuttlebot
  install_mvd

  install_tileserver
  install_cjdns

  install_dnsmasq
  install_nginx

  build_site
  install_adhoc
  restart_dhcpcd
  restart_dnsmasq
  redirect_dns

  update_rclocal
  enable_ssh
  share_hostname
  install_utilities
  echo "--- END" "$(date)"
} &>>$LOG
