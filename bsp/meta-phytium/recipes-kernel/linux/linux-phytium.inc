# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# remove origin kernel and patch in linux-openeuler.inc
SRC_URI:remove = " \
    file://kernel-${PV} \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
"

# fetch kernel and patch for phytium
OPENEULER_REPO_NAME = "phytium-kernel-${PV}"
OPENEULER_REPO_NAMES = "phytium-kernel-${PV} src-kernel-${PV}"

# use phytium kernel repo
SRC_URI:append = " \
    file://phytium-kernel-${PV} \
"

SRC_URI:append = " \
	file://phytiumpi.its \
"

DEPENDS:append = " u-boot-tools-native dtc-native"
do_deploy:append() {
    if [ "${@bb.utils.contains("MACHINE_FEATURES", "sd", "1", "0", d)}" = "1" ]; then
        cp ${WORKDIR}/phytiumpi.its  ./
        uboot-mkimage -f phytiumpi.its  fitImage
        cp fitImage  ${DEPLOY_DIR_IMAGE}/fitImage
    fi
}

# add patch tool to solve patch apply
PATCHTOOL = "git"

S = "${WORKDIR}/phytium-kernel-${PV}"

LINUX_VERSION_EXTENSION:append = "-phytium"
OPENEULER_KERNEL_CONFIG = ""
KBUILD_DEFCONFIG = "phytium_defconfig"
