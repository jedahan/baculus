# This will setup our version of scuttlebot - build with `docker build .`
# Run with `./routerless`
FROM node:8 as scuttlebot

USER node
ENV HOME /home/node
ENV NPM_CONFIG_PREFIX $HOME/.npm/global
RUN mkdir -p $NPM_CONFIG_PREFIX
WORKDIR $HOME

ENV ssb_appname bac

RUN git clone https://github.com/jedahan/broadcast-stream --branch routerless \
  && cd broadcast-stream \
  && npm install

RUN git clone https://github.com/jedahan/multiserver --branch routerless \
  && cd multiserver \
  && npm install

RUN git clone https://github.com/jedahan/scuttlebot --branch routerless \
  && cd scuttlebot \
  && npm install \
  && npm link ../broadcast-stream \
  && npm link ../multiserver

RUN git clone https://github.com/jedahan/mvd --branch routerless \
  && cd mvd \
  && npm install \
  && npm link ../scuttlebot \
  && npm run build

# with dev tools
FROM scuttlebot
USER root
RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y vim net-tools screen socat sudo

# setup non-root tshark
RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y tshark \
  && setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap \
  && groupadd wireshark \
  && chgrp wireshark /usr/bin/dumpcap \
  && usermod -a -G wireshark node

# allow running ip as sudo
RUN usermod -a -G sudo node \
  && echo 'node ALL=NOPASSWD:/sbin/ip' >> /etc/sudoers \
  && echo 'node ALL=NOPASSWD:/usr/bin/tshark' >> /etc/sudoers

# setup ssb_host
USER node
RUN printf '\n\
export ssb_host=$(ip addr show dev eth0 | grep -oE "fe80[0-9a-f:]+")\n\
cd ~/scuttlebot\n\
' >> ~/.bashrc

# by default, remove ipv4 address
CMD export public=$(ip addr show eth0 | grep -oE '[0-9.]+/16') \
  && sudo ip addr del $public dev eth0 \
  && bash
