# main bbfile: yocto-poky/meta/recipes-bsp/u-boot/u-boot_2021.01.bb

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=2ca5f2c35c8cc335f0a19756634782f1"


OPENEULER_REPO_NAME = "uboot-tools"
PV = "2024.01"

DEPENDS += "python3-setuptools-native gnutls util-linux swig-native"

inherit python3native
export STAGING_INCDIR="${STAGING_INCDIR_NATIVE}"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=2ca5f2c35c8cc335f0a19756634782f1"

# apply openEuler package
# file://backport-Provide-a-fallback-to-smbios-tables.patch

SRC_URI = " \
            file://u-boot-${PV}.tar.bz2 \
            file://backport-uefi-distro-load-FDT-from-any-partition-on-boot-device.patch \
            file://backport-disable-VBE-by-default.patch  \
            file://backport-enable-bootmenu-by-default.patch \
            file://backport-uefi-Boot-var-automatic-management-for-removable-medias.patch \
            file://backport-rockchip-Add-initial-support-for-the-PinePhone-Pro.patch \
        "

S = "${WORKDIR}/u-boot-${PV}"

SED_CONFIG_EFI:loongarch64 = ''

# The compilation of u-boot-tools is a bit odd, it uses `git diff` to update the git index
# for some build environments with git < 2.14. (see yocto-poky/meta/recipes-bsp/u-boot/u-boot-tools.inc).
# But the openeuler package doesn't contain git, run `git diff` will cause errors. Considering that the
# version of git in the openEuler-build-container is > 2.14, so remove `git diff`.
do_compile () {
	oe_runmake -C ${S} tools-only_defconfig O=${B}

	# Disable CONFIG_CMD_LICENSE, license.h is not used by tools and
	# generating it requires bin2header tool, which for target build
	# is built with target tools and thus cannot be executed on host.
	sed -i -e "s/CONFIG_CMD_LICENSE=.*/# CONFIG_CMD_LICENSE is not set/" ${SED_CONFIG_EFI} ${B}/.config

	oe_runmake -C ${S} cross_tools NO_SDL=1 O=${B}
}
