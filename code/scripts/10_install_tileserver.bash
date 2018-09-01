#!/bin/bash
set -ex

require false libcairo2-dev
require false libprotobuf-dev
require npm nodejs

sudo -u pi npm install -g tileserver-gl-light

systemctl daemon-reload
systemctl enable tileserver
systemctl start tileserver
