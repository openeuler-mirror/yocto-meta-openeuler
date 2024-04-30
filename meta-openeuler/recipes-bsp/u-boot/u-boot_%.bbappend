# main bbfile: yocto-poky/meta/recipes-bsp/u-boot/u-boot_2021.01.bb

# apply openEuler package
OPENEULER_REPO_NAME = "uboot-tools"

# fix LIC_FILES_CHKSUM
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=2ca5f2c35c8cc335f0a19756634782f1"

PV = "2024.01"

# remove backport-Provide-a-fallback-to-smbios-tables.patch
SRC_URI = " \
            file://${BP}.tar.bz2 \
            file://backport-uefi-distro-load-FDT-from-any-partition-on-boot-device.patch \
            file://backport-disable-VBE-by-default.patch  \
            file://backport-enable-bootmenu-by-default.patch \
            file://backport-uefi-Boot-var-automatic-management-for-removable-medias.patch \
            file://backport-rockchip-Add-initial-support-for-the-PinePhone-Pro.patch \
            file://boot.cmd \
        "

S = "${WORKDIR}/${BP}"
