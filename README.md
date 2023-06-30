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

Project branches
================

Starting with version 3.9.2 there is a new branch introduced that uses intel-next kernel in favor of the mainline kernel. The branch name is live-iamge-intel-next.
This is intended for internal use only. The rationale behind it is that future platforms often lack support in currect kernel which leads to issue in validation efforts.

It has been proven that using intel-next kernel solves multiple issues regarding S3 cycles and problems with graphic card support.

Note: intel-next is intended for internal Intel use and must not be shared outside of Intel.

More information on intel-next kernel is available at:

https://github.com/intel-innersource/os.linux.intelnext.kernel
https://intelpedia.intel.com/IntelNext

Live Image versioning schema
============================

Live Image version number consists of three digits separated by dots: x.y.z

Version should be incremented in the following way:
- **x** - Linux distribution change, like from Fedora to Buildroot
- **y** - Linux distribution update, ex. new Buildroot release or mass packages update
- **z** - changes in packages configuration, packages version, configuration files

Live image releases that use intel-next kernel should include kernel version:
x.y.z_intel-next_<version> e.g. 3.9.2_intel-next_intel-6.4-2023-06-29
