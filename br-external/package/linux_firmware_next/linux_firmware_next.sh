#!/bin/sh

PATH_TO_DL="dl"
PATH_TO_DL_LINUX_FIRMWARE=$PATH_TO_DL"/linux-firmware"
LINUX_FIRMWARE_NEXT_PROPER_FILENAME="linux-firmware-next"
PATH_TO_TAR=$PATH_TO_DL_LINUX_FIRMWARE/linux-firmware-next.tar.xz
PATH_TO_HASH="package/linux-firmware/linux-firmware.hash"
PATH_TO_POST_IMAGE_EFI_GPT="../br-external/board/tboot_live/post-image-efi-gpt.sh"

# These variables may be changed, depending on where the linux-firmware-next folder was downloaded
LINUX_FIRMWARE_NEXT_FILENAME="os.linux.intelnext.firmware"
PATH_TO_LINUX_FIRMWARE_NEXT_PARENT=$PATH_TO_DL_LINUX_FIRMWARE
PATH_TO_LINUX_FIRMWARE_NEXT=$PATH_TO_LINUX_FIRMWARE_NEXT_PARENT"/"$LINUX_FIRMWARE_NEXT_FILENAME

# Validate conditions to perform current script (if the conditions are not met, skip script execution):
#    direcory with linux-firmare-next must exit, and be pointed at path $PATH_TO_LINUX_FIRMWARE_NEXT
#    hash file (linux-firmware.hash) must exist and be located under the path $PATH_TO_HASH (required to calculate new hashes)
#    post-image-efi-gpt.sh must exist and be located under the path $PATH_TO_POST_IMAGE_EFI_GPT (required to increase disk.img size)
validate_condtitions()
{
    # Creates folders where linux-firmware-next.tar.xz will be placed
    if [ ! -d $PATH_TO_DL ]; then
        echo $PATH_TO_DL' does not exist.'
        mkdir $PATH_TO_DL
    fi

    if [ ! -d $PATH_TO_DL_LINUX_FIRMWARE ]; then
        echo $PATH_TO_DL_LINUX_FIRMWARE' does not exist.'
        mkdir $PATH_TO_DL_LINUX_FIRMWARE
    fi

    if [ ! -d $PATH_TO_LINUX_FIRMWARE_NEXT ]; then
        echo $PATH_TO_LINUX_FIRMWARE_NEXT' does not exist. Skip introduction linux-firmware-next.'
        exit 0
    else
        echo "Directory with firmare next: '"$PATH_TO_DL_LINUX_FIRMWARE"' exist. Firmware next can be copied to build folder"
    fi

    # Check if the linux-firmware.hash file exists, if not, skip current script execution
    if [ ! -f $PATH_TO_HASH ]; then
        echo "Error! File "$PATH_TO_HASH" does not exist. Skip introduction linux-firmware-next."
        exit 0
    fi

    # Check if the post-image-efi-gpt.sh file exists, if not, skip current script execution
    if [ ! -f $PATH_TO_POST_IMAGE_EFI_GPT ]; then
        echo "Error! File "$PATH_TO_POST_IMAGE_EFI_GPT" does not exist. Skip introduction linux-firmware-next."
        exit 0
    fi
}

# Create .tar file (linux-firmware-next.tar.xz) based on directory with linux-firmware-next
make_tar()
{
    if [ ! -f $PATH_TO_TAR ]; then
        echo $PATH_TO_TAR' does not exist. Need to be created.'
        echo "tar cJf "$PATH_TO_DL_LINUX_FIRMWARE/linux-firmware-next.tar.xz $PATH_TO_LINUX_FIRMWARE_NEXT "(this operation may take a while)"
        tar -C $PATH_TO_LINUX_FIRMWARE_NEXT_PARENT  --transform="s/$LINUX_FIRMWARE_NEXT_FILENAME/$LINUX_FIRMWARE_NEXT_PROPER_FILENAME/" -cJf $PATH_TO_TAR $LINUX_FIRMWARE_NEXT_FILENAME --checkpoint=.100
    fi
}

# Update makefile linux_firmware.mk to change version (on version with linux firmware next)
update_makefile()
{
    line=$(grep 'LINUX_FIRMWARE_VERSION =' package/linux-firmware/linux-firmware.mk)
    output="LINUX_FIRMWARE_VERSION = next"

    if [ "$line" != "$output" ]; then
        echo "Update version linux firmware to next"
        sed -i "s|$line|$output|" package/linux-firmware/linux-firmware.mk
    fi
}

# Update hash file (linux-firmware.hash):
#    arg $1: file based on which the hash is calculated
#    arg $2: string in the hash file that should be replaced 
update_hash_file()
{
    # find only line where phrase ending the line
    line=$(awk -v phrase=$2 '$0 ~ phrase "$"' $PATH_TO_HASH)
    sha256="$(sha256sum $1 | cut -d' ' -f1)"
    output="sha256  "$sha256"  "$2

    if [ "$line" != "$output" ]; then
        echo "line: '"$line"' update to: '"$output"'"
        sed -i "s|$line|$output|" $PATH_TO_HASH
    fi
}

update_hash_tar()
{
    line=$(grep "linux-firmware-" $PATH_TO_HASH)
    sha256="$(sha256sum $PATH_TO_TAR | cut -d' ' -f1)"
    filename=$(basename $PATH_TO_TAR)
    output="sha256  "$sha256"  "$filename

    if [ "$line" != "$output" ]; then
        echo "line: '"$line"' update to: '"$output"'"
        sed -i "s|$line|$output|" $PATH_TO_HASH
    fi
}

update_hash_license()
{
    tab[0]="LICENCE.Abilis"
    tab[1]="LICENSE.amdgpu"
    tab[2]="LICENCE.Marvell"
    tab[3]="LICENCE.atheros_firmware"
    tab[4]="ath10k/QCA6174/hw3.0/notice_ath10k_firmware-4.txt"
    tab[5]="ath10k/QCA6174/hw2.1/notice_ath10k_firmware-5.txt"
    tab[6]="ath10k/QCA6174/hw3.0/notice_ath10k_firmware-6.txt"
    tab[7]="LICENCE.broadcom_bcm43xx"
    tab[8]="LICENCE.chelsio_firmware"
    tab[9]="LICENCE.cypress"
    tab[10]="LICENCE.fw_sst_0f28"
    tab[11]="LICENCE.ibt_firmware"
    tab[12]="LICENSE.ice_enhanced"
    tab[13]="LICENCE.it913x"
    tab[14]="LICENCE.iwlwifi_firmware"
    tab[15]="LICENCE.microchip"
    tab[16]="LICENCE.moxa"
    tab[17]="LICENCE.qat_firmware"
    tab[18]="LICENCE.qla2xxx"
    tab[19]="LICENCE.ralink-firmware.txt"
    tab[20]="LICENCE.ralink_a_mediatek_company_firmware"
    tab[21]="LICENCE.rtlwifi_firmware.txt"
    tab[22]="LICENCE.ti-connectivity"
    tab[23]="LICENCE.xc4000"
    tab[24]="LICENCE.xc5000"
    tab[25]="LICENCE.xc5000c"
    tab[26]="LICENSE.QualcommAtheros_ar3k"
    tab[27]="LICENSE.QualcommAtheros_ath10k"
    tab[28]="LICENSE.dib0700"
    tab[29]="LICENSE.i915"
    tab[30]="LICENSE.qcom"
    tab[31]="LICENSE.radeon"
    tab[32]="LICENSE.sdma_firmware"
    tab[33]="WHENCE"
    tab[34]="qcom/NOTICE.txt"
    tab[35]="LICENCE.e100"

    for element in "${tab[@]}"; do
        update_hash_file $PATH_TO_LINUX_FIRMWARE_NEXT"/"$element $element
    done
}

update_hash()
{
    update_hash_tar
    update_hash_license
}

# Filesystem based on linux-firmware-next (rootfs.cpio.gz) is to big to fit in disk.img (100MB). Size od disk.img must be increased (512MB) 
update_size_of_img()
{
    line=$(grep 'efi_part_size=' $PATH_TO_POST_IMAGE_EFI_GPT)
    output='efi_part_size=$(( 536870912 / 512 )) # 512MB'

    if [ "$line" != "$output" ]; then
        echo "Update size od disk.img to 512MB"
        sed -i "s|$line|$output|" $PATH_TO_POST_IMAGE_EFI_GPT
    fi
}

validate_condtitions
make_tar
update_makefile
update_hash
update_size_of_img