#!/bin/bash

curl -sL https://deb.nodesource.com/setup_8.x | bash -

export NPM_CONFIG_PREFIX=$HOME/npm
mkdir -p $NPM_CONFIG_PREFIX
grep NPM_CONFIG_PREFIX /etc/environment || {
    echo NPM_CONFIG_PREFIX="$NPM_CONFIG_PREFIX" >> /etc/environment
}

export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
grep PATH /etc/environment || {
    echo PATH="$PATH" >> /etc/environment
}

require npm nodejs
