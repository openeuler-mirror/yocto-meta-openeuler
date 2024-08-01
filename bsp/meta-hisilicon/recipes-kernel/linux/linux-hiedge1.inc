inherit kernel-yocto

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

OPENEULER_REPO_NAMES = "kernel-5.10-tag626 src-kernel-5.10-tag626 HiEdge-driver"

SRC_URI = "file://kernel-5.10-tag626 \
    file://HiEdge-driver/linux/ss626v100-eulerkernel-d8e3bcbbecf.patch \
    file://dtbs/ss626v100-demb-emmc.dts \
    file://meta-data;type=kmeta;destsuffix=meta-data \
"

# remove default patch
SRC_URI:remove = " \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# add BL31
SRC_URI:append = " file://HiEdge-driver/firmware/arm-trusted-firmware-2.5.tar.gz "

S = "${WORKDIR}/kernel-5.10-tag626"

## handling for kernel meta data
# the original get_dirs_with_fragments will include OPENEULER_SP_DIR
# so that all the files under OPENEULER_SP_DIR will be in the file-checksums
# of do_kernel_metadata, which is not necessary
def get_dirs_with_metadata(d):
    extrapaths = []
    extrafiles = []
    extrapathsvalue = (d.getVar("FILESEXTRAPATHS") or "")

    # Remove global openeuler src dir
    openeuler_src_dir = d.getVar("OPENEULER_SP_DIR")
    extrapathsvalue = extrapathsvalue.replace(openeuler_src_dir, "")

    # Remove default flag which was used for checking
    extrapathsvalue = extrapathsvalue.replace("__default:", "")
    extrapaths = extrapathsvalue.split(":")

    # add scc files
    extrapaths += find_sccs(d)
   
    # add patches
    extrapaths += find_patches(d, '')
    for path in extrapaths:
        if path and path + ":True" not in extrafiles:
            extrafiles.append(path + ":" + str(os.path.exists(path)))

    return " ".join(extrafiles)

# override the original get_dirs_with_fragments in kernel-yocto.bbclass
do_kernel_metadata[file-checksums] = "${@get_dirs_with_metadata(d)}"


# no external defconfig
OPENEULER_KERNEL_CONFIG = ""
# use in-tree defconfig, the defconfig is in src tree
# after patches are unpatched
KBUILD_DEFCONFIG = "ss626v100_emmc_defconfig"

# add method to do_compile task to produce bootable Image
do_compile:append(){
    mkimage -A arm64 -O linux -T kernel -C none -a 0x000000 -e 0x000000 -n "Linux-5.10.0" -d ${KERNEL_OUTPUT_DIR}/Image uImage-tmp
    oe_runmake dtbs
    dtc -I dts -O dtb ${WORKDIR}/dtbs/ss626v100-demb-emmc.dts -o ${WORKDIR}/ss626.dtb
    cat uImage-tmp ${WORKDIR}/ss626.dtb > ${KERNEL_OUTPUT_DIR}/uImage-edge
}

# uImage as bl33, we need to use it to build the fip.bin. So add uImage to SYSROOT_DIR
# Since sysroot_stage_all() is rewritten as empty in meta/classes/kernel.bbclass,
# we can't use "SYSROOT_DIRS" directly, here we write a SYSROOT_PREPROCESS_FUNCS to add uImage
SYSROOT_DIRS += "/linux-img"
FILES:${KERNEL_PACKAGE_NAME} += "/linux-img"
do_install:append() {
        install -d ${D}/linux-img
        install -m 0644 ${KERNEL_OUTPUT_DIR}/uImage-edge ${D}/linux-img/uImage-edge
}

SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot"
additional_populate_sysroot() {
    sysroot_stage_dir ${D}/linux-img ${SYSROOT_DESTDIR}/linux-img
}

