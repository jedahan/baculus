#!/bin/bash

grep baculus.mesh /etc/hosts >/dev/null && return
test "$HOSTNAME" || return
printf "
127.0.0.1 baculus %s
10.0.42.1 baculus.mesh baculus.map baculus.chat baculus.portal
" "$HOSTNAME" | tee -a /etc/hosts
