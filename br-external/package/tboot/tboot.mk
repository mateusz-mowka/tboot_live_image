################################################################################
#
# tboot
#
################################################################################
TBOOT_VERSION = v1.10.5
TBOOT_SITE = http://hg.code.sf.net/p/tboot/code
TBOOT_SITE_METHOD = hg
TBOOT_DEPENDENCIES = openssl
TBOOT_INSTALL_IMAGES = YES
TBOOT_INSTALL_TARGET = YES

define TBOOT_CONFIGURE_CMDS
	# empty, no configure step in tboot
endef

define TBOOT_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/tboot/tboot.gz $(BINARIES_DIR)/tboot.gz
endef

$(eval $(autotools-package))
