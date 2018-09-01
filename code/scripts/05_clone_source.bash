#!/bin/bash

require git
test -d /home/pi/baculus || sudo -u pi git clone https://github.com/baculus-buoy/baculus.git $_
