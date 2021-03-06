SUMMARY = "Linux kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM ?= "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel

SRC_URI = "file://kernel-5.10 \
     file://yocto-embedded-tools/config/${ARCH}/defconfig-kernel \
"
# add patches only for aarch64
SRC_URI_append_aarch64 += " \
    file://yocto-embedded-tools/patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# add patches for OPENEULER_PLATFROM such as aarch64-pro
SRC_URI_append_aarch64-pro += " \
    file://src-kernel-5.10/0000-raspberrypi-kernel.patch \
    file://src-kernel-5.10/0001-add-preemptRT-patch.patch \
    file://src-kernel-5.10/0002-modifty-bcm2711_defconfig-for-rt-rpi-kernel.patch \
"

S = "${WORKDIR}/kernel-5.10"

LINUX_VERSION ?= "5.10"
LINUX_VERSION_EXTENSION_append = "-openeuler"
#delete v8 in kernel module name, such as kernel-module-xxx-5.10.0-v8
KERNEL_MODULE_PACKAGE_SUFFIX = ""

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
OPENEULER_KERNEL_CONFIG_aarch64-pro = "${S}/arch/${ARCH}/configs/bcm2711_defconfig"
do_configure_prepend() {
    if [[ ${OPENEULER_PLATFORM} == "aarch64-pro" ]]; then
        sed -i '$a CONFIG_ACPI=y' ${OPENEULER_KERNEL_CONFIG}
    fi
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}

do_install_append(){
    install -m 0644 ${KERNEL_OUTPUT_DIR}/Image ${D}/${KERNEL_IMAGEDEST}/Image-${KERNEL_VERSION}
}

#not found depmodwrapper, not run postinst now
pkg_postinst_${KERNEL_PACKAGE_NAME}-base () {
    :
}
