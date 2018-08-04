#!/bin/bash
# baculus update script
set -ex
HOME=/home/pi
LOG=$HOME/log/baculus.log
INSTALL_LOG=$HOME/log/install.log

change_locale() {
  sudo raspi-config nonint do_change_locale 'en_US.UTF-8'
}

install_baculus() {
  grep '^installed baculus$' $INSTALL_LOG && return
  echo 'installing baculus'
  git clone https://github.com/baculus-buoy/baculus.git
  pushd baculus
  sudo apt install -y ruby ruby-dev
  bundle --version || sudo gem install bundler
  bundle install
  bundle exec jekyll build
  pushd _site
  sed -i -e 's/^.*oogle.*$//' *html */*html
  popd # _site
  popd # baculus
  echo 'installed baculus' >> $INSTALL_LOG
}

configure_npm() {
  which node >/dev/null || {
    sudo apt install -y nodejs
  }
  which npm >/dev/null || {
    sudo apt install -y npm
  }
  export NPM_CONFIG_PREFIX=$HOME/npm/global
  mkdir -p $NPM_CONFIG_PREFIX
  grep NPM_CONFIG_PREFIX /etc/environment || {
    echo NPM_CONFIG_PREFIX=$NPM_CONFIG_PREFIX | sudo tee -a /etc/environment
  }
  export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
  grep PATH /etc/environment || {
    echo PATH=$PATH | sudo tee -a /etc/environment
  }
}

install_tileserver() {
  grep '^installed tileserver$' $INSTALL_LOG && return
  echo 'installing tileserver'
  npm install -g tileserver-gl-light
  pushd $HOME/baculus/code
  cp home/pi/tileserver.json $HOME/
  cp -r home/pi/tiles $HOME/
  sudo cp etc/systemd/system/tileserver.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable tileserver
  sudo systemctl start tileserver
  popd # ~/baculus/code
  echo 'installed tileserver' >> $INSTALL_LOG
}

meshpoint() {
  test -f $HOME/meshpoint.sh || {
  echo 'installing meshpoint.sh'
    cp $HOME/baculus/code/home/pi/meshpoint.sh $HOME/meshpoint.sh
    echo 'installed meshpoint.sh'
  }
  bash $HOME/meshpoint.sh
}

adhoc() {
  lsmod | grep 8192cu && sudo rmmod 8192cu
  sudo modprobe rtl8192cu
  test -f $HOME/adhoc.sh || {
  echo 'installing adhoc.sh'
    cp $HOME/baculus/code/home/pi/adhoc.sh $HOME/adhoc.sh
    echo 'installed adhoc.sh'
  }
  bash $HOME/adhoc.sh
}

configure_nginx() {
  grep 'configured nginx' $INSTALL_LOG && return
  echo 'configuring nginx'
  sudo cp $HOME/baculus/code/etc/nginx/sites-available/baculus /etc/nginx/sites-available/
  sudo ln -s /etc/nginx/sites-available/baculus /etc/nginx/sites-enabled/baculus
  sudo rm /etc/nginx/sites-enabled/default
  sudo systemctl enable nginx
  echo 'configured nginx' >> $INSTALL_LOG
}

configure_hosts() {
  grep "configured hosts" $INSTALL_LOG && return
  echo 'configuring hosts'
  local config=/etc/hosts
  printf "
127.0.0.1 baculus $HOSTNAME
10.0.42.1 baculus.mesh baculus.map baculus.chat
" | sudo tee -a $config
  echo 'configured hosts' >> $INSTALL_LOG
}

configure_dnsmasq() {
  grep '^configured dnsmasq$' $INSTALL_LOG && return
  echo 'configuring dnsmasq'
  sudo cp $HOME/baculus/code/etc/dnsmasq.conf /etc/
  echo 'configured dnsmasq' >> $INSTALL_LOG
}

update_rclocal() {
  grep '^updated rclocal$' $INSTALL_LOG && return
  echo 'updating rclocal'
  printf \ '
# setup adhoc mode
/home/pi/adhoc.sh
ip addr
' | sudo tee -a /etc/rc.local
  echo 'updated rc.local' >> $INSTALL_LOG
}

install_scuttlebot() {
  grep '^installed scuttlebot$' $INSTALL_LOG && return
  echo 'installing scuttlebot'
  cd $HOME
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
  # appname
  echo ssb_appname=bac | sudo tee -a /etc/environment
  echo 'installed scuttlebot' >> $INSTALL_LOG
}

install_mvd() {
  grep '^installed mvd$' $INSTALL_LOG && return
  echo 'installing mvd'
  cd $HOME
  git clone https://github.com/jedahan/mvd --branch routerless
  pushd mvd
  git checkout d8a4a9ffc444a9daa612ede79049083a4ce1ca7c
  npm install
  npm link ../scuttlebot
  popd # mvd
  echo 'installed mvd' >> $INSTALL_LOG
}

install_cjdns() {
  grep '^installed cjdns$' $INSTALL_LOG && return
  echo 'installing cjdns'
  cd $HOME
  git clone https://github.com/cjdelisle/cjdns.git
  pushd cjdns
  git pull
  git checkout 77259a49e5bc7ca7bc6dca5bd423e02be563bdc5
  NO_TEST=1 Seccomp_NO=1 ./do
  sudo cp cjdroute /usr/bin/
  cjdroute --genconf | sed -e 's/"bind": "all"/"bind": "eth0"/' | sudo tee /etc/cjdroute.conf
  sudo cp contrib/systemd/cjdns* /etc/systemd/system/
  popd #cjdns
  echo 'installed cjdns' >> $INSTALL_LOG
}

install_everything() {
  echo "--- START" $(date)
  change_locale
  install_baculus
  configure_npm
  install_cjdns
  configure_dnsmasq
  configure_nginx
  install_scuttlebot
  install_mvd
  install_tileserver
  adhoc
  update_rclocal
  echo "--- END" $(date)
}

test -d $(dirname $LOG) || mkdir -p $(dirname $LOG)
touch $LOG || exit 1
cd $HOME || exit 1
install_everything &>>$LOG
