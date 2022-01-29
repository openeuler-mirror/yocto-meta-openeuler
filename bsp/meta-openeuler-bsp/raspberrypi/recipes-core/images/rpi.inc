delete_boot_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    pushd "${IMAGE_ROOTFS}"
    if [ -d ./boot ];then
        rm -f "${OUTPUT_DIR}"/*Image* "${OUTPUT_DIR}"/vmlinux*
        mv boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
        mv boot/vmlinux* "${OUTPUT_DIR}"/
        mv boot/Image* "${OUTPUT_DIR}"// || exit 1
        rm -r ./boot
    fi
    popd
}

copy_openeuler_distro() {
    rm -f "${OUTPUT_DIR}"/initrd
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES} "${OUTPUT_DIR}"/initrd
}

IMAGE_PREPROCESS_COMMAND += "delete_boot_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"


#IMAGE_FEATURES += "splash"
IMAGE_FSTYPES = "wic.gz"

#not depends to native parted/mtools and so on, use host command
export OPENEULER_WIC_IMAGE_REMOVE = "parted gptfdisk dosfstools mtools"
python() {
    all_depends = d.getVarFlag("do_image_wic", "depends")
    bb.note("all depends of do_image_wic: %s" % all_depends)
    for dep in ('parted', 'gptfdisk', 'dosfstools', 'mtools'):
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    d.setVarFlag("do_image_wic", "depends", new_depends)
    bb.note("new depends of do_image_wic: %s" % new_depends)
}
