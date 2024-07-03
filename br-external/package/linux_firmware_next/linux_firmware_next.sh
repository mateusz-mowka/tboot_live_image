#!/bin/bash

FIRMWARE_PATH="os.linux.intelnext.firmware/"
BUILD_PATH="../build/build/linux-firmware-next/i915"

rm -rf $BUILD_PATH

git clone --filter=blob:none --no-checkout https://github.com/intel-innersource/os.linux.intelnext.firmware

git -C $FIRMWARE_PATH sparse-checkout set --no-cone /i915 '!*/i915'
git -C $FIRMWARE_PATH checkout master

cp -r $FIRMWARE_PATH"i915" $BUILD_PATH

rm -rf $FIRMWARE_PATH