Buildroot based Live Image idea
===============================

Buildroot is a system that allows to build whole Linux using provided recipes. Recipes are stored in this repository and uses build-in Buildroot external-tree feature to integrate with existing Buildroot release.

Buildroot itself is included as git submodule, so can be fetched directly from this repository with correct version. Any changes added to this project should not required using special Buildroot version. There are many mechanisms in Buildroot that allow to fulfill that requirement.

Global configuration is stored in tboot_live_defconfig, there are paths to other configuration files that resides in tboot_live board directory. There is also post-build script that appends current version to GRUB config file and prepared disk image.

Building process
================

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

**How to change TBOOT version**

Modify `br-external/package/tboot/tboot.mk` put new hash into TBOOT_VERSION variable.

**How to change Buildroot configuration**

- run
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build menuconfig
```
- do some changes
- save new configuration
```
make BR2_EXTERNAL=$PWD/br-external -C buildroot O=$PWD/build savedefconfig
```

**How to change Linux kernel configuration**

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

Live Image versioning schema
============================

Live Image version number consists of three digits separated by dots: x.y.z 

Version should be incremented in the following way:
- **x** - Linux distribution change, like from Fedora to Buildroot
- **y** - Linux distribution update, ex. new Buildroot release or mass packages update
- **z** - changes in packages configuration, packages version, configuration files

Historically there were two major TBOOT Live Image releases, first based on Ubuntu, second on Fedora. That's why Buildroot based release starts with 3.0.0 version.