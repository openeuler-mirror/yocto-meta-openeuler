# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# add patch prebuild tools and logo
SRC_URI:remove = " \
    file://kernel-5.10 \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

## basic information
OPENEULER_REPO_NAME = "rockchip-kernel"
# download src-openeuler/kernel repo for patches
OPENEULER_MULTI_REPOS = "rockchip-kernel"

SRC_URI:append = " \
    file://rockchip-kernel \
"

INHIBIT_PACKAGE_STRIP = "1"

# mcs patch for ok3568 devicetree
SRC_URI:append:ok3568 = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'file://patches/0003-ok3568-support-mcs.patch', '', d)} \
"

S = "${WORKDIR}/rockchip-kernel"

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
