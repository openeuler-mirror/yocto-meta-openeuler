delete_boot_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    pushd "${IMAGE_ROOTFS}"
    if [ -d ./boot ];then
        rm -f "${OUTPUT_DIR}"/*Image* "${OUTPUT_DIR}"/vmlinux*
        mv boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
        mv boot/vmlinux* "${OUTPUT_DIR}"/
        rm -r ./boot
    fi
    popd
}

copy_openeuler_distro() {
    rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES}
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES} "${OUTPUT_DIR}"/
}

IMAGE_PREPROCESS_COMMAND += "delete_boot_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"


#IMAGE_FEATURES += "splash"
IMAGE_FSTYPES = "rpi-sdimg"
SDIMG_ROOTFS_TYPE = "ext4"
EXTRA_IMAGECMD_ext4 += "-E no_copy_xattrs"


#not depends to native parted/mtools and so on, use host command
export OPENEULER_WIC_IMAGE_REMOVE = "parted dosfstools mtools"
python() {
    all_depends = d.getVarFlag("do_image_rpi_sdimg", "depends")
    bb.note("all depends of do_image_rpi_sdimg: %s" % all_depends)
    for dep in ('parted', 'gptfdisk', 'dosfstools', 'mtools'):
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    d.setVarFlag("do_image_rpi_sdimg", "depends", new_depends)
    bb.note("new depends of do_image_rpi_sdimg: %s" % new_depends)

    all_depends = d.getVarFlag("do_image_ext4", "depends")
    bb.note("all depends of do_image_ext4: %s" % all_depends)
    for dep in ['e2fsprogs']:
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    d.setVarFlag("do_image_ext4", "depends", new_depends)
    bb.note("new depends of do_image_ext4: %s" % new_depends)
}
