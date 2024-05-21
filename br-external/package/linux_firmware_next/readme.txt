This script was created for use in live image the latest version of linux firmware (linux-firmware-next).

How to use:
1. Download the linux-firware-next to proper localization:
    a) default path: tboot_live_image/buildroot/dl/linux-firmware directory name: os.linux.intelnext.firmware
    b) change path variable in script: 
        LINUX_FIRMWARE_NEXT_FILENAME -> directory name (default: os.linux.intelnext.firmware)
        PATH_TO_LINUX_FIRMWARE_NEXT_PARENT -> path to direcoty contain folder with linux-firmare-next (default: tboot_live_image/buildroot/dl/linux-firmware)
        PATH_TO_LINUX_FIRMWARE_NEXT -> path to linux-firmare-next (default: tboot_live_image/buildroot/dl/linux-firmware/os.linux.intelnext.firmware)

    To download linux-firmware-next use command: git clone https://github.com/intel-innersource/os.linux.intelnext.firmware
2. To update buildroot config use command: make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build tboot_live_defconfig
3. Compile. Size of disk.img should be 512MB