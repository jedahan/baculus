# Baculus Build Log

This is a log on how to setup a raspberry pi with everything you need to create your own baculus node. 

## Preparation

Gather the following materials. (A working backpack already has these installed)

* computer with [Docker](https://www.docker.com/get-started) installed
* microSD card + microSD adapter
* raspberry pi 3 model b or b+
* copy of this repository

## Creating the image

We use Docker to create and customize `rpi.img`, which will be etched onto a microSD card for the Raspberry Pi. This lets us create updated images without needing the individual Raspberry Pis to be connected.

Start by [installing docker](https://www.docker.com/get-started) for your platform.



Next, open up a terminal, and clone this repository somewhere



    git clone github.com/baculus-buoy/baculus && cd baculus/code



Now we are ready to create an image! 

To make an image, pick whatever hostname you want, and run `make HOSTNAMEHERE.rpi.img`, for example:



    make baculusA.rpi.img



Once the image is built, we can etch it onto a microSD card. Install [etcher](https://etcher.io/) (or etcher-cli) and point it to the image:



    sudo etcher share/build/baculusA.rpi.img



Put the microSD card into a raspberry pi, turn it on, and after a minute or two you should see a 'baculus' wifi network up.

![wifi](images/8_wifi.png)



You can connect to this network and start chatting!