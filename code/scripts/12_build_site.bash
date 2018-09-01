#!/bin/bash
set -ex

require gem ruby ruby-dev
pushd /home/pi/baculus
command -v bundle >/dev/null 2>&1 || gem install bundler
sudo -u pi bundle install
sudo -u pi bundle exec jekyll build
