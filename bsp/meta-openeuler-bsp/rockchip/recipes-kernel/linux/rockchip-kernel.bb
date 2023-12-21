require recipes-kernel/linux/linux-openeuler.inc

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

OPENEULER_KERNEL_CONFIG = ""
SRC_URI:remove = "file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch"

# For orangepi5, use rockchip-kernel
python do_fetch:append() {
    # download openEuler/rockchip-kernel repo for linux kernel src
    d.setVar("OPENEULER_REPO_NAME", "rockchip-kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'rockchip-kernel')
    bb.build.exec_func("do_openeuler_fetch", d)
}

SRC_URI = " \
    file://rockchip-kernel \
    file://patches/0001-add-dtb-for-rk3588s-orangepi-5.patch \
    file://patches/0002-disable-CONFIG_WL_ROCKCHIP-and-CONFIG_DYNAMIC_FTRACE.patch \
"
S = "${WORKDIR}/rockchip-kernel"

COMPATIBLE_MACHINE = "orangepi5"
