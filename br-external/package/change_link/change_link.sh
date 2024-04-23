#!/bin/sh

path_to_dl="dl"
path_to_dl_linux_firmware=$path_to_dl"/linux-firmware"
path_to_dl_linux_firmware_next_parent=$path_to_dl_linux_firmware
linux_firmware_next_filename="os.linux.intelnext.firmware"
linux_firmware_next_proper_filename="linux-firmware-next"
path_to_dl_linux_firmware_next=$path_to_dl_linux_firmware_next_parent"/"$linux_firmware_next_filename
path_to_tar=$path_to_dl_linux_firmware/linux-firmware-next.tar.xz
path_to_hash="package/linux-firmware/linux-firmware.hash"

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

    if [ ! -f $path_to_hash ]; then
        echo "Error! File "$path_to_hash" does not exist. Skip..."
    fi
}

makeTar()
{
    if [ ! -f $path_to_tar ]; then
        echo $path_to_tar' does not exist.'
        echo "tar cJf "$path_to_dl_linux_firmware/linux-firmware-next.tar.xz $path_to_dl_linux_firmware_next "(this may take a while)"
        tar -C $path_to_dl_linux_firmware_next_parent  --transform="s/$linux_firmware_next_filename/$linux_firmware_next_proper_filename/" -cJf $path_to_tar $linux_firmware_next_filename --checkpoint=.100
    fi
}

updateMakefile()
{
    line=$(grep 'LINUX_FIRMWARE_VERSION =' package/linux-firmware/linux-firmware.mk)
    output="LINUX_FIRMWARE_VERSION = next"

    sed -i "s|$line|$output|" package/linux-firmware/linux-firmware.mk
}

updateHshFile()
{
    line=$(grep $2 $path_to_hash)
    sha256="$(sha256sum $1 | cut -d' ' -f1)"
    filename=$(basename $1)
    echo "sha256 " $sha256 " " $filename

    output="sha256 "$sha256" "$filename
    sed -i "s|$line|$output|" $path_to_hash  
}

updateHashTar()
{
    echo "Update Tar Hash"
    updateHshFile $path_to_tar "linux-firmware-"
}

updateHashLicense()
{
    echo "Update License Hash"
    tab=(
        "LICENCE.Abilis"
        "LICENSE.amdgpu"
        "LICENCE.Marvell"
        "LICENCE.atheros_firmware"
        "ath10k/QCA6174/hw3.0/notice_ath10k_firmware-4.txt"
        "ath10k/QCA6174/hw2.1/notice_ath10k_firmware-5.txt"
        "ath10k/QCA6174/hw3.0/notice_ath10k_firmware-6.txt"
        "LICENCE.broadcom_bcm43xx"
        "LICENCE.chelsio_firmware"
        "LICENCE.cypress"
        "LICENCE.fw_sst_0f28"
        "LICENCE.ibt_firmware"
        "LICENSE.ice_enhanced"
        "LICENCE.it913x"
        "LICENCE.iwlwifi_firmware"
        "LICENCE.microchip"
        "LICENCE.moxa"
        "LICENCE.qat_firmware"
        "LICENCE.qla2xxx"
        "LICENCE.ralink-firmware.txt"
        "LICENCE.ralink_a_mediatek_company_firmware"
        "LICENCE.rtlwifi_firmware.txt"
        "LICENCE.ti-connectivity"
        "LICENCE.xc4000"
        "LICENCE.xc5000"
        "LICENCE.xc5000c"
        "LICENSE.QualcommAtheros_ar3k"
        "LICENSE.QualcommAtheros_ath10k"
        "LICENSE.dib0700"
        "LICENSE.i915"
        "LICENSE.qcom"
        "LICENSE.radeon"
        "LICENSE.sdma_firmware"
        "WHENCE"
        "qcom/NOTICE.txt"
        "LICENCE.e100"
    );

    for element in "${tab[@]}"; do
        updateHshFile $path_to_dl_linux_firmware_next"/"$element $element
    done
}

updateHash()
{
    updateHashTar
    updateHashLicense
}

checkFirmwareNextExist
makeTar
updateMakefile
updateHash