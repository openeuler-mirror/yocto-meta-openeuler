inherit kernel-yocto

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native"

SRC_URI = "file://kernel-5.10-tag928 \
    file://HiEuler-driver/linux/5.10.0-153.28.0.patch \
    file://dtbs/ss928-pi.dts \
    file://meta-data;type=kmeta;destsuffix=meta-data \
"

# remove default patch
SRC_URI:remove = " \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

# add BL31
SRC_URI:append = " file://HiEuler-driver/firmware/trusted-firmware-a-2.2.tar.gz "

S = "${WORKDIR}/kernel-5.10-tag928"

python do_fetch() {
    # download HiEuler repo for patches
    d.setVar("OPENEULER_REPO_NAME", "HiEuler-driver")
    d.setVar("OPENEULER_LOCAL_NAME", 'HiEuler-driver')
    bb.build.exec_func("do_openeuler_fetch", d)

    # download src-openeuler/kernel repo for patches
    d.setVar("OPENEULER_REPO_NAME", "kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'src-kernel-5.10-tag928')
    bb.build.exec_func("do_openeuler_fetch", d)

    # download openeuler/kernel-5.10 repo for linux kernel src files
    d.setVar("OPENEULER_REPO_NAME", "kernel-5.10")
    d.setVar("OPENEULER_LOCAL_NAME", 'kernel-5.10-tag928')
    bb.build.exec_func("do_openeuler_fetch", d)
}

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
KBUILD_DEFCONFIG = "hieulerpi1_defconfig"

# add method to do_compile task to produce bootable Image
do_compile:append(){
    mkimage -A arm64 -O linux -T kernel -C none -a 0x080000 -e 0x080000 -n "Linux-5.10.0" -d ${KERNEL_OUTPUT_DIR}/Image uImage-tmp
    oe_runmake dtbs
    dtc -I dts -O dtb ${WORKDIR}/dtbs/ss928-pi.dts -o ${WORKDIR}/ss928-pi.dtb
    cat uImage-tmp ${WORKDIR}/ss928-pi.dtb > ${KERNEL_OUTPUT_DIR}/uImage-pi
}

# uImage as bl33, we need to use it to build the fip.bin. So add uImage to SYSROOT_DIR
# Since sysroot_stage_all() is rewritten as empty in meta/classes/kernel.bbclass,
# we can't use "SYSROOT_DIRS" directly, here we write a SYSROOT_PREPROCESS_FUNCS to add uImage
SYSROOT_DIRS += "/linux-img"
FILES:${KERNEL_PACKAGE_NAME} += "/linux-img"
do_install:append() {
        install -d ${D}/linux-img
        install -m 0644 ${KERNEL_OUTPUT_DIR}/uImage-pi ${D}/linux-img/uImage-pi
}

SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot"
additional_populate_sysroot() {
    sysroot_stage_dir ${D}/linux-img ${SYSROOT_DESTDIR}/linux-img
}

