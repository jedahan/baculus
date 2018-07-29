all: build

build:
	docker build -t scuttlebot:dev .

net: build
	cmd=/bin/bash $(MAKE) run

run: build
	docker run -it \
--sysctl net.ipv6.conf.all.disable_ipv6=0 \
--cap-add NET_ADMIN \
--cap-add NET_BROADCAST \
--mount 'type=bind,source=/Volumes/data/code/scuttlebot,destination=/home/node/scuttlebot' \
scuttlebot:dev ${cmd}
