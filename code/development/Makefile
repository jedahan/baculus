all: build

build:
	docker build -t scuttlebot:dev .
	
run:
	docker run -it \
--sysctl net.ipv6.conf.all.disable_ipv6=0 \
--cap-add NET_ADMIN \
--cap-add NET_BROADCAST \
scuttlebot:dev
