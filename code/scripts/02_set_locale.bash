#!/bin/bash

test "$LANG" = 'en_US.UTF-8' || raspi-config nonint do_change_locale 'en_US.UTF-8'
export LANG=en_US.UTF-8
export LANGUAGE=$LANG
raspi-config nonint do_configure_keyboard us
raspi-config nonint do_wifi_country US
raspi-config nonint do_ssh 0
