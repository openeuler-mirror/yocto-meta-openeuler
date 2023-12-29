delete_unneeded_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    cd "${IMAGE_ROOTFS}"
    if [ -d ./boot ];then
        rm -f "${OUTPUT_DIR}"/*Image* "${OUTPUT_DIR}"/vmlinux*
        mv boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
        mv boot/vmlinux* "${OUTPUT_DIR}"/
        rm -r ./boot
    fi
    cd -
}
copy_openeuler_distro() {
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${IMAGE_FSTYPES} ${OUTPUT_DIR}/rootfs.img
    cp -fp ${DEPLOY_DIR_IMAGE}/uImage ${OUTPUT_DIR}/
}

IMAGE_PREPROCESS_COMMAND_append = "delete_unneeded_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND_append = " copy_openeuler_distro;"

IMAGE_FSTYPES_DEBUGFS = "ext4"
IMAGE_FSTYPES = "ext4"
