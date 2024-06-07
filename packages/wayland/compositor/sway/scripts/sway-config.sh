#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

export XDG_RUNTIME_DIR=/var/run/0-runtime-dir
export WAYLAND_DISPLAY=wayland-1
SWAY_DAEMON_ARGS=""

SWAY_RUNTIME_DIR=/var/run/sway
SWAY_CONFIG_BASEDIR=/storage/.config/sway
SWAY_CONFIG_SHAREDIR=/usr/share/sway

SWAY_CONFIG_COLOR=${SWAY_CONFIG_BASEDIR}/colorscheme
SWAY_CONFIG_COLOR_DEFAULT=${SWAY_CONFIG_SHAREDIR}/colorscheme
SWAY_CONFIG_DAEMON=${SWAY_CONFIG_BASEDIR}/sway-daemon.conf
SWAY_CONFIG_DAEMON_DEFAULT=${SWAY_CONFIG_SHAREDIR}/sway-daemon.conf
SWAY_CONFIG_USER=${SWAY_CONFIG_BASEDIR}/config
SWAY_CONFIG_USER_DEFAULT=${SWAY_CONFIG_SHAREDIR}/config.kiosk
SWAY_CONFIG_RUN=${SWAY_RUNTIME_DIR}/sway-daemon.conf

if [ ! -d "$XDG_RUNTIME_DIR" ]; then
  mkdir "$XDG_RUNTIME_DIR"
  chmod 0700 "$XDG_RUNTIME_DIR"
fi

if [ ! -d "$SWAY_RUNTIME_DIR" ]; then
  mkdir "$SWAY_RUNTIME_DIR"
fi

if [ ! -d ${SWAY_CONFIG_BASEDIR} ]; then
  mkdir -p ${SWAY_CONFIG_BASEDIR}
fi

if [ ! -f ${SWAY_CONFIG_COLOR} ]; then
  cp ${SWAY_CONFIG_COLOR_DEFAULT} ${SWAY_CONFIG_BASEDIR}
fi

if [ ! -f ${SWAY_CONFIG_DAEMON} ]; then
  cp ${SWAY_CONFIG_DAEMON_DEFAULT} ${SWAY_CONFIG_BASEDIR}
fi

if [ -f ${SWAY_CONFIG_DAEMON} ] ; then
   SWAY_DAEMON_CONF=$(cat ${SWAY_CONFIG_DAEMON} | grep -E '^SWAY_DAEMON_CONF=' | cut -d "\"" -f2)
fi

echo SWAY_DAEMON_ARGS=\"${SWAY_DAEMON_CONF} ${SWAY_DAEMON_ARGS}\" > ${SWAY_CONFIG_RUN}

# Copy default config to user config
rm -f ${SWAY_CONFIG_USER}
cp ${SWAY_CONFIG_USER_DEFAULT} ${SWAY_CONFIG_BASEDIR}

# Generate user config by scanning connectors
card_no=$(ls /sys/class/drm/ | grep -E "HDMI|DSI" | head -n 1 | cut -b 5)
card=/sys/class/drm/card${card_no}
for connector in ${card}/card${card_no}*/
do
    con=$(basename $connector)
    con=${con: +6}
    output="output ${con}"
    # If dsi check rotation
    if [[ $con  == "DSI"* ]]; then
        rot=$(cat /sys/class/graphics/fbcon/rotate)
        case $rot in
            1) angle="90";;
            2) angle="180";;
            3) angle="270";;
            *) angle="0";;
        esac
        echo "${output} transform ${angle}" >> $SWAY_CONFIG_USER
    fi
    echo "${output} bg #000000 solid_color" >> $SWAY_CONFIG_USER
    echo "${output} max_render_time off" >> $SWAY_CONFIG_USER
done
