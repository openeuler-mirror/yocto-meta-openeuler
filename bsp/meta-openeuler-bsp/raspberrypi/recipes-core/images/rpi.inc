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
