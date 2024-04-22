#!/bin/sh

line=$(grep 'LINUX_FIRMWARE_VERSION =' package/linux-firmware/linux-firmware.mk)
output="LINUX_FIRMWARE_VERSION = test"

sed -i "s|$line|$output|" package/linux-firmware/linux-firmware.mk