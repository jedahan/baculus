#!/bin/bash
set -ex

require gem ruby ruby-dev
pushd ~/baculus
command -v bundle >/dev/null 2>&1 || sudo gem install bundler
bundle install
bundle exec jekyll build
