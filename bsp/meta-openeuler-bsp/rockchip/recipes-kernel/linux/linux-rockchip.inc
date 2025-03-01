# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# remove openeuler's default kernel and patches, rockchip's kernel
# is maintained in https://gitee.com/openeuler/rockchip-kernel.git
SRC_URI:remove = " \
    file://kernel-5.10 \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

## basic information
OPENEULER_LOCAL_NAME = "rockchip-kernel"
OPENEULER_REPO_NAMES = "rockchip-kernel"

OPENEULER_LOCAL_NAME:tspi-3566 = "rockchip-kernel-tspi-3566"
OPENEULER_REPO_NAMES:tspi-3566 = "rockchip-kernel-tspi-3566"

SRC_URI:append = " \
    file://rockchip-kernel \
"

SRC_URI:remove:tspi-3566 = " \
    file://rockchip-kernel \
"

SRC_URI:append:tspi-3566 = " \
    file://rockchip-kernel-tspi-3566 \
"

INHIBIT_PACKAGE_STRIP = "1"

# mcs patch for ok3568 devicetree
SRC_URI:append:ok3568 = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'file://patches/0003-ok3568-support-mcs.patch', '', d)} \
"

# add tspi-3566 device tree
SRC_URI:append:tspi-3566 = " \
    file://patches/0001-add-tspi-3566-device-tree.patch \
"

S = "${WORKDIR}/rockchip-kernel"

# tspi kernel directory
S:tspi-3566 = "${WORKDIR}/rockchip-kernel-tspi-3566"

OPENEULER_KERNEL_CONFIG = "file://config/${SOC_FAMILY}/defconfig"

# mkimg need use dtc command
DEPENDS += "dtc-native"

# Hack for rockchip style images incase you need boot.img
python () {
    if not d.getVar('KERNEL_DEVICETREE'):
        raise bb.parse.SkipPackage('KERNEL_DEVICETREE is not specified!')

    if d.getVar('ROCKCHIP_KERNEL_IMAGES'):
        # Use rockchip stype target, which is '<dts(w/o suffix)>.img'
        d.setVar('KERNEL_IMAGETYPE_FOR_MAKE', ' ' + d.getVar('KERNEL_DEVICETREE').replace('rockchip/', '').replace('.dtb', '.img'));
}

do_compile:append(){
    install ${B}/*.img ${B}/${KERNEL_OUTPUT_DIR}/
}
