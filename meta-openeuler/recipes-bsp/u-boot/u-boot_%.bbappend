# main bbfile: yocto-poky/meta/recipes-bsp/u-boot/u-boot_2021.01.bb

# apply openEuler package
OPENEULER_REPO_NAME = "uboot-tools"

PV = "2024.01"

SRC_URI = " \
            file://${BP}.tar.bz2 \
            file://backport-uefi-distro-load-FDT-from-any-partition-on-boot-device.patch \
            file://backport-disable-VBE-by-default.patch  \
            file://backport-Provide-a-fallback-to-smbios-tables.patch \
            file://backport-enable-bootmenu-by-default.patch \
            file://backport-uefi-Boot-var-automatic-management-for-removable-medias.patch \
            file://backport-rockchip-Add-initial-support-for-the-PinePhone-Pro.patch \
        "

S = "${WORKDIR}/${BP}"
