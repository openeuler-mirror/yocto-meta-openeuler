# main bbfile: yocto-poky/meta/recipes-bsp/u-boot/u-boot_2021.01.bb

# apply openEuler package
OPENEULER_REPO_NAME = "uboot-tools"
OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "2021.10"

SRC_URI=  "file://u-boot-2021.10.tar.bz2 \
           file://backport-uefi-distro-load-FDT-from-any-partition-on-boot-device.patch \
           file://backport-CVE-2022-34835.patch \
           file://backport-CVE-2022-33967.patch \
           file://backport-CVE-2022-30767.patch \
          "

S = "${WORKDIR}/u-boot-${PV}"
