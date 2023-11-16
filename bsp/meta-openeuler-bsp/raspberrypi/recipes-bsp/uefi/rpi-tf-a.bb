SUMMARY = "ARM Trusted Firmware for Raspberry Pi 4"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

BPN = "arm-trusted-firmware"
PV = "2.6"

OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI = "file://${OPENEULER_LOCAL_NAME}/${BPN}/${BP}.tar.gz \
           file://0001-RPI3-RPI4-revert-rpi3_pwr_down_wfi.patch \
        "

SRC_URI[md5sum] = "2622f7077e30436b2310bea0232c7cec"
SRC_URI[sha256sum] = "3905a6d6affa84fb629d1565a4e4bdc82812bba49a457b8249ab445eeb28011b"

# overide LDFLAGS to allow rpi4 TF-A to build without: "aarch64-openeuler-linux-gnu-ld.bfd: unrecognized option '-Wl,-O1'"
export LDFLAGS=""

EXTRA_OEMAKE="CROSS_COMPILE=${TARGET_PREFIX} "
export LDFLAGS=""

do_compile:append() {
    oe_runmake PLAT=rpi4 RPI3_PRELOADED_DTB_BASE=0x1F0000 PRELOADED_BL33_BASE=0x20000 SUPPORT_VFP=1 SMC_PCI_SUPPORT=1 DEBUG=0 all
}

do_install:append() {
    install -d ${D}${datadir}
    install ${B}/build/rpi4/release/bl31.bin ${D}${datadir}
}

FILES:${PN} += "${datadir}/bl31.bin"
