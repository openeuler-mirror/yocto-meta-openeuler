# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

KERNEL_VERSION_SANITY_SKIP = "1"

# not support kernel6 now for 3591
OPENEULER_REPO_NAMES = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        not-support-kernel6-for-3591 \
    ', ' \
        kernel-5.10-tag3591 \
    ', d)} \
"

PV = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'not-support-kernel6-for-3591', '5.10-tag3591', d)}"

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
	 \
    ', ' \
        file://patch/3591rc/0001-add-3591-bsp-depends.patch \
	file://patch/3591rc/0001-add-3591b-net-support-ascend-milan-support-hns3.patch \
        file://patch/3591rc/0002-add-securec-source-for-3591.patch \
        file://patch/3591rc/0001-add-cert-for-3591.patch \
        file://patch/3591rc/make_oee_ko_compat.patch \
    ', d)} \
"

# remove default patch
SRC_URI:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
    ', ' \
        file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    ', d)} \
"

# use yocto's defconfig file
OPENEULER_KERNEL_CONFIG = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'file://config/3591rc/3591b_defconfig', 'file://config/3591rc/3591p_defconfig', d)}"

# for in-tree defconfig
KBUILD_DEFCONFIG = ""

do_compile:append(){
}

