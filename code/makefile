IMAGE_NAME := baculus.rpi.img

MAKEFLAGS += --warn-undefined-variables
BOOT := build/boot.tar
ROOT := build/root.tar
COMBINED := build/combined.tar
BACULUS := build/$(IMAGE_NAME)

.DEFAULT_GOAL := $(IMAGE_NAME)

clean:
	rm -f build/{combined,root}.tar
	
build:
	docker pull alpi-maker

$(ROOT).xz:
	curl -L http://vx2-downloads.raspberrypi.org/raspbian_lite/archive/2018-06-29-03:25/root.tar.xz -o $@
	
$(BOOT).xz:
	curl -L http://vx2-downloads.raspberrypi.org/raspbian_lite/archive/2018-06-29-03:25/boot.tar.xz -o $@
	
$(ROOT): $(ROOT).xz
	cp $^ $^.bak
	test -f $@ || unxz $^
	mv $^.bak $^
  	
$(COMBINED): $(ROOT) $(BOOT).xz
	cd build && \
	mkdir -p boot && \
	tar -xf boot.tar.xz -C boot && \
	sudo chown -R 0 boot && \
	sudo chgrp -R 0 boot && \
	cp root.tar combined.tar && \
	tar -rf combined.tar boot && \
	sudo rm -rf boot
	
%.rpi.img: $(COMBINED)
	docker run -it --privileged \
		--volume ${PWD}:/tmp \
		-e OS_IMAGE="combined.tar" \
		-e SCRIPT_DIR="/tmp/scripts" \
		-e COPY_DIR="/tmp/files" \
		-e SETUP_SCRIPT="/tmp/setup" \
		-e HOSTNAME=$(@:.rpi.img=) \
		-e IMAGE_SIZE=4G \
		-e IMAGE_NAME=$@ \
		"alpi-maker"
	mv build/$@ .
	echo "$@ built successfully! flash with etcher $@"
