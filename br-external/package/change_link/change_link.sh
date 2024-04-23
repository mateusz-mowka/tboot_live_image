#!/bin/sh

path_to_dl="dl"
path_to_dl_linux_firmware=$path_to_dl"/linux-firmware"
path_to_dl_linux_firmware_next=$path_to_dl_linux_firmware"/os.linux.intelnext.firmware"
path_to_tar=$path_to_dl_linux_firmware/linux-firmware-next.tar.xz

checkFirmwareNextExist()
{
    # pwd
    # echo "patch to dl=" $path_to_dl

    if [ ! -d $path_to_dl ]; then
        echo $path_to_dl' does not exist.'
        mkdir $path_to_dl
    else
        echo $path_to_dl' exist.'
    fi

    # echo "patch to dl linux firmware=" $path_to_dl_linux_firmware

    if [ ! -d $path_to_dl_linux_firmware ]; then
        echo $path_to_dl_linux_firmware' does not exist.'
        mkdir $path_to_dl_linux_firmware
    else
        echo $path_to_dl_linux_firmware' exist.'
    fi

    # echo "patch to dl linux firmware next=" $path_to_dl_linux_firmware_next

    if [ ! -d $path_to_dl_linux_firmware_next ]; then
        echo $path_to_dl_linux_firmware_next' does not exist. Skip...'
        exit 0
    else
        echo $path_to_dl_linux_firmware' exist. Firmware next can be copied to build folder'
    fi
}

makeTar()
{
    if [ ! -f $path_to_tar ]; then
        echo $path_to_tar' does not exist.'
        echo "tar cJf "$path_to_dl_linux_firmware/linux-firmware-next.tar.xz $path_to_dl_linux_firmware_next "(this may take a while)"
        tar cJf $path_to_dl_linux_firmware/linux-firmware-next.tar.xz $path_to_dl_linux_firmware_next --checkpoint=.100
    fi
}

updateMakefile()
{
    line=$(grep 'LINUX_FIRMWARE_VERSION =' package/linux-firmware/linux-firmware.mk)
    output="LINUX_FIRMWARE_VERSION = next"

    sed -i "s|$line|$output|" package/linux-firmware/linux-firmware.mk
}

checkFirmwareNextExist
makeTar
updateMakefile