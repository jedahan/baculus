#!/bin/bash
set -ex

rm -f /etc/nginx/sites-enabled/default
require nginx
systemctl enable nginx
