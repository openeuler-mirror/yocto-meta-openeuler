SUMMARY = "Linux kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM ?= "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel
#require recipes-kernel/linux/linux-yocto.inc

SRC_URI = "file://kernel-5.10 \
     file://yocto-embedded-tools/config/${ARCH}/defconfig-kernel \
"
SRC_URI_append_aarch64 += " \
    file://yocto-embedded-tools/patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"
S = "${WORKDIR}/kernel-5.10"

LINUX_VERSION ?= "5.10"
LINUX_VERSION_EXTENSION_append = "-openeuler"

PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "qemuarm|qemuarmv5|qemuarm64|qemux86|qemuppc|qemuppc64|qemumips|qemumips64|qemux86-64|qemuriscv64|qemuriscv32|qemu-aarch64|qemu-arm|raspberrypi4-64"

PACKAGES += "${KERNEL_PACKAGE_NAME}-img"
FILES_${KERNEL_PACKAGE_NAME}-img = "/boot/Image-${KERNEL_VERSION}"


# Skip processing of this recipe if it is not explicitly specified as the
# PREFERRED_PROVIDER for virtual/kernel. This avoids network access required
# by the use of AUTOREV SRCREVs, which are the default for this recipe.
python () {
    if d.getVar("KERNEL_PACKAGE_NAME") == "kernel" and d.getVar("PREFERRED_PROVIDER_virtual/kernel") != d.getVar("PN"):
        d.delVar("BB_DONT_CACHE")
        raise bb.parse.SkipRecipe("Set PREFERRED_PROVIDER_virtual/kernel to %s to enable it" % (d.getVar("PN")))
}

KERNEL_CC_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"

OPENEULER_KERNEL_CONFIG = "../yocto-embedded-tools/config/${ARCH}/defconfig-kernel"
do_configure_prepend() {
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

do_install_append(){
    install -m 0644 ${KERNEL_OUTPUT_DIR}/Image ${D}/${KERNEL_IMAGEDEST}/Image-${KERNEL_VERSION}
}

#not found depmodwrapper, not run postinst now
pkg_postinst_${KERNEL_PACKAGE_NAME}-base () {
    :
}
