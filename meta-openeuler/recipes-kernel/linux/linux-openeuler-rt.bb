require recipes-kernel/linux/linux-openeuler.inc

SRC_URI_append_aarch64 += " \
    file://src-kernel-5.10/0000-kernel-5.10.0-136.8.0-rt62.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

SRC_URI_append_x86-64 += " \
    file://src-kernel-5.10/0000-kernel-5.10.0-136.8.0-rt62.patch \
    file://src-kernel-5.10/0001-modify-openeuler_defconfig-for-rt62.patch \
"

COMPATIBLE_MACHINE = "qemu-aarch64|qemu-x86-64"

do_configure_prepend() {
    sed -i 's/CONFIG_PREEMPT=y/CONFIG_PREEMPT_RT=y/g' ${OPENEULER_KERNEL_CONFIG}
    cp -f "${OPENEULER_KERNEL_CONFIG}" .config
}
