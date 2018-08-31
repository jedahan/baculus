#!/bin/bash
set -ex

test -f /etc/nginx/sites-enabled/default && sudo rm "$_"
require nginx
sudo systemctl enable nginx
  