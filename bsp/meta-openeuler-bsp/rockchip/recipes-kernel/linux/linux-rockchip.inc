# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS_append := "${THISDIR}/files/:"
# add patch prebuild tools and logo
SRC_URI_remove = " \
    file://kernel-5.10 \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    "
python do_fetch() {
    # download src-openeuler/kernel repo for patches
    d.setVar("OPENEULER_REPO_NAME", "kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'src-rockchip-kernel')
    bb.build.exec_func("do_openeuler_fetch", d)

    # download openeuler/kernel-5.10 repo for linux kernel src files
    d.setVar("OPENEULER_REPO_NAME", "rockchip-kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'rockchip-kernel')
    bb.build.exec_func("do_openeuler_fetch", d)
}

SRC_URI_append = " \
    file://rockchip-kernel \
    file://config/${MACHINE}/${MACHINE}_defconfig \
"

INHIBIT_PACKAGE_STRIP = "1"
# patches for ryd-3568
SRC_URI_append_ryd-3568 = " \
    file://patches/0001-rk3568-8897-dts.patch \
    file://patches/0002-ryd-gpio-control.patch \
    file://meta-data;type=kmeta;destsuffix=meta-data \
    "
# mcs patch for ok3568 devicetree
SRC_URI_append = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'file://patches/0003-ok3568-support-mcs.patch', '', d)} \
"

# add patch tool to solve patch apply
PATCHTOOL = "git"

S = "${WORKDIR}/rockchip-kernel"

OPENEULER_KERNEL_CONFIG = "../config/${MACHINE}/${MACHINE}_defconfig"

# Hack for rockchip style images
KERNEL_IMAGETYPES += \
	"${@'boot.img zboot.img' if d.getVar('ROCKCHIP_KERNEL_IMAGES') == '1' else ''}"
python () {
    if not d.getVar('KERNEL_DEVICETREE'):
        raise bb.parse.SkipPackage('KERNEL_DEVICETREE is not specified!')

    if d.getVar('ROCKCHIP_KERNEL_IMAGES'):
        # Use rockchip stype target, which is '<dts(w/o suffix)>.img'
        d.setVar('KERNEL_IMAGETYPE_FOR_MAKE', ' ' + d.getVar('KERNEL_DEVICETREE').replace('rockchip/', '').replace('.dtb', '.img'));
}

do_install_prepend(){
    install ${B}/*.img "${B}/arch/arm64/boot/"
}

do_deploy_append(){
    install ${B}/boot.img "${DEPLOYDIR}/boot.img"
}
