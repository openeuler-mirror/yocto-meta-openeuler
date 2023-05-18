# main bbfile: yocto-poky/meta/recipes-bsp/u-boot/u-boot_2021.01.bb

# apply openEuler package
OPENEULER_REPO_NAME = "uboot-tools"
PV = "2021.10"
SRC_URI = "file://u-boot-2021.10.tar.bz2 \
           file://backport-uefi-distro-load-FDT-from-any-partition-on-boot-device.patch \
           file://backport-CVE-2022-34835.patch \
           file://backport-CVE-2022-33967.patch \
           file://backport-CVE-2022-30767.patch \
          "

S = "${WORKDIR}/u-boot-${PV}"

# The compilation of u-boot-tools is a bit odd, it uses `git diff` to update the git index
# for some build environments with git < 2.14. (see yocto-poky/meta/recipes-bsp/u-boot/u-boot-tools.inc).
# But the openeuler package doesn't contain git, run `git diff` will cause errors. Considering that the
# version of git in the openEuler-build-container is > 2.14, so remove `git diff`.
do_compile () {
	oe_runmake -C ${S} sandbox_defconfig O=${B}

	# Disable CONFIG_CMD_LICENSE, license.h is not used by tools and
	# generating it requires bin2header tool, which for target build
	# is built with target tools and thus cannot be executed on host.
	sed -i -e "s/CONFIG_CMD_LICENSE=.*/# CONFIG_CMD_LICENSE is not set/" ${SED_CONFIG_EFI} ${B}/.config

	oe_runmake -C ${S} cross_tools NO_SDL=1 O=${B}
}
