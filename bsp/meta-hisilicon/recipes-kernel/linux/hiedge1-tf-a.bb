SUMMARY = "ARM Trusted Firmware for hiedge1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

BPN = "arm-trusted-firmware"
PV = "2.5"

OPENEULER_LOCAL_NAME = "HiEdge-driver"

# 0001-fix-compilation-errors-atf-asm.patch is a workaround to fix ld err:
#  undefined reference to `OS_SYS_CTRL_REG2' 
#  undefined reference to `OS_SYS_CTRL_REG4'
SRC_URI = "file://HiEdge-driver/firmware/${BP}.tar.gz \
           file://HiEdge-driver/firmware/${BP}.patch \
           file://tf-a/0001-add-LDFLAGS-to-fix-compilation-errors.patch \
           file://tf-a/0001-fix-compilation-errors-atf-asm.patch \
        "

SRC_URI[md5sum] = "23d7f30f393a20dcced3df1284ba0daa"
SRC_URI[sha256sum] = "f178c722374b0cdf2d7ca3ab986d494e02c49b4690dd8b1cf2d1c9a5388b374e"

# override LDFLAGS to fix compilation error: "aarch64-openeuler-linux-gnu-ld.bfd: unrecognized option '-Wl,-O1'"
# add --no-warn-rwx-segments to avoid: warning: <file> has a LOAD segment with RWX permissions
export LDFLAGS=" --no-warn-rwx-segments "

# tf-a requires dtc native
DEPENDS += "dtc-native"

# uImage as BL33
DEPENDS += "virtual/kernel"

EXTRA_OEMAKE="CROSS_COMPILE=${TARGET_PREFIX} "

do_compile:append() {
    oe_runmake PLAT=ss626v100 SPD=none BL33=${WORKDIR}/recipe-sysroot/linux-img/uImage-edge CCI_UP=0 DEBUG=0 BL33_SEC=0 fip
    cp ${B}/build/ss626v100/release/fip.bin ${B}/build/ss626v100/release/fip-edge.bin
}

do_install:append() {
    install -d ${D}/boot/
    install ${B}/build/ss626v100/release/fip-edge.bin ${D}/boot/kernel-edge
}

FILES:${PN} += " /boot/kernel-edge "
