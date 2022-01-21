delete_boot_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    pushd "${IMAGE_ROOTFS}"
    rm -f "${OUTPUT_DIR}"/*Image* "${OUTPUT_DIR}"/initrd "${OUTPUT_DIR}"/vmlinux*
    mv boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
    mv boot/vmlinux* "${OUTPUT_DIR}"/
    mv boot/Image* "${OUTPUT_DIR}"/
    rm -r ./boot
    touch lsm
    popd
}

copy_openeuler_distro() {
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES} "${OUTPUT_DIR}"/initrd
}

IMAGE_PREPROCESS_COMMAND += "delete_boot_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"
