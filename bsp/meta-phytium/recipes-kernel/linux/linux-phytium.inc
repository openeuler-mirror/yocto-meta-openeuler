# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# remove origin kernel and patch in linux-openeuler.inc
SRC_URI:remove = " \
    file://kernel-${PV} \
    file://src-kernel-${PV} \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
"

# fetch kernel and patch for phytium
OPENEULER_REPO_NAME = "phytium-kernel-${PV}"
OPENEULER_REPO_NAMES = "phytium-kernel-${PV} src-kernel-${PV}-tag-phytium"

# use phytium kernel repo
SRC_URI:append = " \
    file://phytium-kernel-${PV} \
    file://src-kernel-${PV}-tag-phytium \
"

# patches for ft2000-4
SRC_URI:append:ft2000-4 = " \
    file://patches/0001-allow-ACPI-AML-cover-the-kernel-memory.patch \
"

SRC_URI:append:phytiumpi = " \
	file://phytiumpi.its \
"

DEPENDS:append:phytiumpi = " u-boot-tools-native dtc-native"
do_deploy:append:phytiumpi() {
    cp ${WORKDIR}/${MACHINE}.its  ./
    uboot-mkimage -f ${MACHINE}.its  fitImage
    cp fitImage  ${DEPLOY_DIR_IMAGE}/fitImage
}

# add patch tool to solve patch apply
PATCHTOOL = "git"

S = "${WORKDIR}/phytium-kernel-${PV}"

OPENEULER_KERNEL_CONFIG = "file://${CONFIGVERSION}config/${MACHINE}/${MACHINE}_defconfig"
