#!/bin/bash

#
# This script taken your locally built Kernel/arch/arm/boot/zImage and
# stuffs it into epicmtd-kernel.zip, ready to flash in CWM.
#
# Copyright 2012 Warren Togami <wtogami@gmail.com>
# License: BSD

# Abort on error
. include/functions
set -e

if [ ! -f ./Kernel/arch/arm/boot/zImage ]; then
  echo "ERROR: File not found: ./Kernel/arch/arm/boot/zImage"
  echo 
  echo "       Run build_kernel.sh first?"
  echo
  exit 255
fi

if [ "$CM_BUILD" != "epicmtd" ]; then
  echo "ERROR: You must breakfast cm_epicmtd-userdebug and make bacon before running this script."
  echo
  exit 255
fi

if [ ! -f tools/cwm-zip/META-INF/com/google/android/update-binary ]; then
  if [ -f ../../../out/target/product/epicmtd/system/bin/updater ]; then
    vcp ../../../out/target/product/epicmtd/system/bin/updater tools/cwm-zip/META-INF/com/google/android/update-binary
  elif [ -f ../../../out/target/product/epicmtd/symbols/system/bin/updater ]; then
    # Check if unstripped updater is built (-userdebug), if so copy and strip it
    vcp ../../../out/target/product/epicmtd/symbols/system/bin/updater tools/cwm-zip/META-INF/com/google/android/update-binary
    find_toolchain
    echo $TCPATH/arm-eabi-strip tools/cwm-zip/META-INF/com/google/android/update-binary
    $TCPATH/arm-eabi-strip tools/cwm-zip/META-INF/com/google/android/update-binary
  else
    echo "ERROR: File not found: ../../../out/target/product/epicmtd/system/bin/updater"
    echo "                                             OR"
    echo "                       ../../../out/target/product/epicmtd/symbols/system/bin/updater"
    echo 
    echo "       You probably need to 'make bacon' in order to build it, or manually put a binary at"
    echo "       tools/cwm-zip/META-INF/com/google/android/update-binary"
    echo
    exit 255
  fi
fi

# Copy other files
vcp ../../../out/target/product/epicmtd/utilities/bml_over_mtd tools/cwm-zip/
vcp ../../../device/samsung/epicmtd/bml_over_mtd.sh            tools/cwm-zip/
vcp ../../../out/target/product/epicmtd/utilities/busybox      tools/cwm-zip/
vcp ../../../out/target/product/epicmtd/utilities/erase_image  tools/cwm-zip/
vcp ../../../out/target/product/epicmtd/utilities/flash_image  tools/cwm-zip/

# Build boot.img
cd ../../..
rm -rf out/target/product/epicmtd/ramdisk/
rm -rf out/target/product/epicmtd/root/
rm -rf out/target/product/epicmtd/ramdisk.img
rm -rf out/target/product/epicmtd/boot.img
make   out/target/product/epicmtd/boot.img
cd - > /dev/null

# Copy boot.img
vcp ../../../out/target/product/epicmtd/boot.img tools/cwm-zip/boot.img

rm -f epicmtd-kernel.zip
cd tools/cwm-zip/
zip -r ../../epicmtd-kernel.zip *
cd - > /dev/null

echo
echo "SUCCESS: epicmtd-kernel.zip complete."
echo 
