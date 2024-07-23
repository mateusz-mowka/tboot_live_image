#!/bin/bash

FIRMWARE_PATH="os.linux.intelnext.firmware/"
BUILD_PATH="../build/build/linux-firmware-next/i915"

# Remove old i915 files from live image
rm -rf $BUILD_PATH

# Clone intelnext repo without downloading any files
git clone --filter=blob:none --no-checkout https://github.com/intel-innersource/os.linux.intelnext.firmware

# Set git to download only i915 folder
git -C $FIRMWARE_PATH sparse-checkout set --no-cone /i915 '!*/i915'
git -C $FIRMWARE_PATH checkout master

# Copy i915 folder from intelnext repo to live image
cp -r $FIRMWARE_PATH"i915" $BUILD_PATH

# Remove intelnext repo
rm -rf $FIRMWARE_PATH