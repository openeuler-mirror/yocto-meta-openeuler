require recipes-kernel/linux/linux-openeuler.inc

LICENSE = "GPLv2"
LIC_FILES_CHKSUM ?= "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRC_URI = " \
    file://kernel-5.10 \
    file://yocto-embedded-tools/config/${ARCH}/defconfig-kernel \
"

SRC_URI_append_aarch64 += " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI_append_x86-64 += " \
    file://src-kernel-5.10/0001-apply-preempt-RT-patch.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

S = "${WORKDIR}/kernel-5.10"

LINUX_VERSION ?= "5.10"
PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "qemu-aarch64|qemu-x86-64"

do_configure_prepend() {
    sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_RT=y/g' ${OPENEULER_KERNEL_CONFIG}
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}
