TBOOT Live Image
================

Steps for building Live Image
-----------------------------

Only Linux is supported, tested on Fedora 29.

- clone this repository
- fetch buildroot submodule
```
git submodule update --init
```
- load buildroot config
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build tboot_live_defconfig
```
- build image
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build all
```
- output image will be at `build/images/disk.img` it can be written to USB disk using dd comamnd or similar software

This Live Image build does not include any SINIT, it has to be copied directly to USB disk, grub.cfg should be modified to load proper SINIT file

FAQ
---

#### How to change TBOOT version ####
Modify `br-external/package/tboot/tboot.mk` put new hash into TBOOT_VERSION variable.

#### How to change Buildroot configuration ####
- run
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build menuconfig
```
- do some changes
- save new configuration
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build savedefconfig
```

#### How to change Linux kernel configuration ####
- run
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build linux-menuconfig
```
- do some changes
- save new configuration
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build linux-savedefconfig
```
- copy new defconfig to br-external folder
```
cp build/build/linux-4.19.25/defconfig br-external/board/tboot_live/linux.config
```
