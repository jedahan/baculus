#!/bin/bash
set -ex

require false libcairo2-dev
require false libprotobuf-dev
require npm nodejs
npm install -g tileserver-gl-light
sudo systemctl daemon-reload
sudo systemctl enable tileserver
sudo systemctl start tileserver
