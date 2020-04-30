################################################################################
#
# grub2-repow
#
################################################################################
GRUB2_REPO_VERSION = c543d678105037afebb4fdea1fb7e423da3cb3cb # currently latest version
GRUB2_REPO_SITE = https://git.savannah.gnu.org/git/grub.git
GRUB2_REPO_SITE_METHOD = git
GRUB2_REPO_LICENSE = GPL-3.0+
GRUB2_REPO_LICENSE_FILES = COPYING
GRUB2_REPO_DEPENDENCIES = host-bison host-flex host-grub2-repo
HOST_GRUB2_REPO_DEPENDENCIES = host-bison host-flex
GRUB2_REPO_INSTALL_IMAGES = YES

ifeq ($(BR2_TARGET_GRUB2_REPO_INSTALL_TOOLS),y)
GRUB2_REPO_INSTALL_TARGET = YES
else
GRUB2_REPO_INSTALL_TARGET = NO
endif

GRUB2_REPO_BUILTIN_MODULES = $(call qstrip,$(BR2_TARGET_GRUB2_REPO_BUILTIN_MODULES))
GRUB2_REPO_BUILTIN_CONFIG = $(call qstrip,$(BR2_TARGET_GRUB2_REPO_BUILTIN_CONFIG))
GRUB2_REPO_BOOT_PARTITION = $(call qstrip,$(BR2_TARGET_GRUB2_REPO_BOOT_PARTITION))

ifeq ($(BR2_TARGET_GRUB2_REPO_I386_PC),y)
GRUB2_REPO_IMAGE = $(BINARIES_DIR)/grub.img
GRUB2_REPO_CFG = $(TARGET_DIR)/boot/grub/grub.cfg
GRUB2_REPO_PREFIX = ($(GRUB2_REPO_BOOT_PARTITION))/boot/grub
GRUB2_REPO_TUPLE = i386-pc
GRUB2_REPO_TARGET = i386
GRUB2_REPO_PLATFORM = pc
else ifeq ($(BR2_TARGET_GRUB2_REPO_I386_EFI),y)
GRUB2_REPO_IMAGE = $(BINARIES_DIR)/efi-part/EFI/BOOT/bootia32.efi
GRUB2_REPO_CFG = $(BINARIES_DIR)/efi-part/EFI/BOOT/grub.cfg
GRUB2_REPO_PREFIX = /EFI/BOOT
GRUB2_REPO_TUPLE = i386-efi
GRUB2_REPO_TARGET = i386
GRUB2_REPO_PLATFORM = efi
else ifeq ($(BR2_TARGET_GRUB2_REPO_X86_64_EFI),y)
GRUB2_REPO_IMAGE = $(BINARIES_DIR)/efi-part/EFI/BOOT/bootx64.efi
GRUB2_REPO_CFG = $(BINARIES_DIR)/efi-part/EFI/BOOT/grub.cfg
GRUB2_REPO_PREFIX = /EFI/BOOT
GRUB2_REPO_TUPLE = x86_64-efi
GRUB2_REPO_TARGET = x86_64
GRUB2_REPO_PLATFORM = efi
else ifeq ($(BR2_TARGET_GRUB2_REPO_ARM_UBOOT),y)
GRUB2_REPO_IMAGE = $(BINARIES_DIR)/boot-part/grub/grub.img
GRUB2_REPO_CFG = $(BINARIES_DIR)/boot-part/grub/grub.cfg
GRUB2_REPO_PREFIX = ($(GRUB2_REPO_BOOT_PARTITION))/boot/grub
GRUB2_REPO_TUPLE = arm-uboot
GRUB2_REPO_TARGET = arm
GRUB2_REPO_PLATFORM = uboot
else ifeq ($(BR2_TARGET_GRUB2_REPO_ARM_EFI),y)
GRUB2_REPO_IMAGE = $(BINARIES_DIR)/efi-part/EFI/BOOT/bootarm.efi
GRUB2_REPO_CFG = $(BINARIES_DIR)/efi-part/EFI/BOOT/grub.cfg
GRUB2_REPO_PREFIX = /EFI/BOOT
GRUB2_REPO_TUPLE = arm-efi
GRUB2_REPO_TARGET = arm
GRUB2_REPO_PLATFORM = efi
else ifeq ($(BR2_TARGET_GRUB2_REPO_ARM64_EFI),y)
GRUB2_REPO_IMAGE = $(BINARIES_DIR)/efi-part/EFI/BOOT/bootaa64.efi
GRUB2_REPO_CFG = $(BINARIES_DIR)/efi-part/EFI/BOOT/grub.cfg
GRUB2_REPO_PREFIX = /EFI/BOOT
GRUB2_REPO_TUPLE = arm64-efi
GRUB2_REPO_TARGET = aarch64
GRUB2_REPO_PLATFORM = efi
endif

# Grub2 is kind of special: it considers CC, LD and so on to be the
# tools to build the host programs and uses TARGET_CC, TARGET_CFLAGS,
# TARGET_CPPFLAGS, TARGET_LDFLAGS to build the bootloader itself.
#
# NOTE: TARGET_STRIP is overridden by !BR2_STRIP_strip, so always
# use the cross compile variant to ensure grub2 builds

HOST_GRUB2_REPO_CONF_ENV = \
	CPP="$(HOSTCC) -E"

GRUB2_REPO_CONF_ENV = \
	CPP="$(TARGET_CC) -E" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS) -fno-stack-protector" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	TARGET_NM="$(TARGET_NM)" \
	TARGET_OBJCOPY="$(TARGET_OBJCOPY)" \
	TARGET_STRIP="$(TARGET_CROSS)strip"

GRUB2_REPO_CONF_OPTS = \
	--target=$(GRUB2_REPO_TARGET) \
	--with-platform=$(GRUB2_REPO_PLATFORM) \
	--prefix=/ \
	--exec-prefix=/ \
	--disable-grub-mkfont \
	--enable-efiemu=no \
	ac_cv_lib_lzma_lzma_code=no \
	--enable-device-mapper=no \
	--enable-libzfs=no

HOST_GRUB2_REPO_CONF_OPTS = \
	--disable-grub-mkfont \
	--enable-efiemu=no \
	ac_cv_lib_lzma_lzma_code=no \
	--enable-device-mapper=no \
	--enable-libzfs=no

define GRUB2_REPO_RUN_BOOTSTRAP
	(cd $(@D); \
		GNULIB_URL="https://git.sv.gnu.org/git/gnulib" \
		./bootstrap \
	)
endef
GRUB2_REPO_PRE_CONFIGURE_HOOKS += GRUB2_REPO_RUN_BOOTSTRAP
HOST_GRUB2_REPO_PRE_CONFIGURE_HOOKS += GRUB2_REPO_RUN_BOOTSTRAP


ifeq ($(BR2_TARGET_GRUB2_REPO_I386_PC),y)
define GRUB2_REPO_IMAGE_INSTALL_ELTORITO
	cat $(HOST_DIR)/lib/grub/$(GRUB2_REPO_TUPLE)/cdboot.img $(GRUB2_REPO_IMAGE) > \
		$(BINARIES_DIR)/grub-eltorito.img
endef
endif

define GRUB2_REPO_INSTALL_IMAGES_CMDS
	mkdir -p $(dir $(GRUB2_REPO_IMAGE))
	$(HOST_DIR)/usr/bin/grub-mkimage \
		-d $(@D)/grub-core/ \
		-O $(GRUB2_REPO_TUPLE) \
		-o $(GRUB2_REPO_IMAGE) \
		-p "$(GRUB2_REPO_PREFIX)" \
		$(if $(GRUB2_REPO_BUILTIN_CONFIG),-c $(GRUB2_REPO_BUILTIN_CONFIG)) \
		$(GRUB2_REPO_BUILTIN_MODULES)
	mkdir -p $(dir $(GRUB2_REPO_CFG))
	$(INSTALL) -D -m 0644 boot/grub2/grub.cfg $(GRUB2_REPO_CFG)
	$(GRUB2_REPO_IMAGE_INSTALL_ELTORITO)
endef

ifeq ($(GRUB2_REPO_PLATFORM),efi)
define GRUB2_REPO_EFI_STARTUP_NSH
	echo $(notdir $(GRUB2_REPO_IMAGE)) > \
		$(BINARIES_DIR)/efi-part/startup.nsh
endef
GRUB2_REPO_POST_INSTALL_IMAGES_HOOKS += GRUB2_REPO_EFI_STARTUP_NSH
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
