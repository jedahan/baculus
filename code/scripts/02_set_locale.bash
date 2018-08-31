#!/bin/bash

test "$LANG" = 'en_US.UTF-8' || sudo raspi-config nonint do_change_locale 'en_US.UTF-8'
export LANG=en_US.UTF-8
export LANGUAGE=$LANG
sudo raspi-config nonint do_configure_keyboard us
sudo raspi-config nonint do_wifi_country US
sudo raspi-config nonint do_ssh 0
