# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# remove origin kernel and patch in linux-openeuler.inc
SRC_URI:remove = " \
    file://kernel-5.10 \
    file://src-kernel-5.10 \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# fetch kernel and patch for phytium
OPENEULER_MULTI_REPOS = "phytium-kernel src-kernel-5.10-tag-phytium"

python do_fetch() {
    bb.build.exec_func("do_openeuler_fetch_multi", d)
}

# use phytium kernel repo
SRC_URI:append = " \
    file://phytium-kernel \
    file://src-kernel-5.10-tag-phytium \
"

# patches for ft2000-4
SRC_URI:append:ft2000-4 = " \
    file://patches/0001-allow-ACPI-AML-cover-the-kernel-memory.patch \
"

# add patch tool to solve patch apply
PATCHTOOL = "git"

S = "${WORKDIR}/phytium-kernel"

OPENEULER_KERNEL_CONFIG = "file://config/${MACHINE}/${MACHINE}_defconfig"
