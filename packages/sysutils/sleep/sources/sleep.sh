#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Fewtarius (https://github.com/fewtarius)

. /etc/profile

case $1 in
  pre)

    if [ "${DEVICE_FAKE_JACKSENSE}" == "true" ]
    then
      systemctl stop headphones
    fi

    if [ "${DEVICE_VOLUMECTL}" == "true" ]
    then
      systemctl stop volume
    fi

    # RG351x devices are notorious for losing USB when they sleep.
    if [[ "${HW_DEVICE}" =~ RG351 ]]
    then
      modprobe -r dwc2
    fi

    alsactl store -f /storage/.config/asound.state

    touch /run/.last_sleep_time

  ;;
  post)
    alsactl restore -f /storage/.config/asound.state

    if [[ "${HW_DEVICE}" =~ RG351 ]]
    then
      modprobe -i dwc2
    fi

    if [ "${DEVICE_FAKE_JACKSENSE}" == "true" ]
    then
      systemctl start headphones
    fi

    if [ "${DEVICE_VOLUMECTL}" == "true" ]
    then
      systemctl start volume
    fi

    if [ "$(get_setting wifi.enabled)" == "1" ]
    then
      wifictl reconnect
    fi

    DEVICE_VOLUME=$(get_setting "audio.volume" 2>/dev/null)
    amixer -M set "${DEVICE_AUDIO_MIXER}" ${DEVICE_VOLUME}% 2>&1 >/dev/null

    BRIGHTNESS_DEV="$(ls /sys/class/backlight | head -n 1)"
    BRIGHTNESS=$(get_setting system.brightness)
    echo ${BRIGHTNESS} >/sys/class/backlight/${BRIGHTNESS_DEV}/brightness
  ;;
esac
