delete_unneeded_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    pushd "${IMAGE_ROOTFS}"
    rm -f "${OUTPUT_DIR}"/*Image* "${OUTPUT_DIR}"/vmlinux*
    cp boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
    mv boot/vmlinux* "${OUTPUT_DIR}"/
    if [[ ! "${KERNEL_IMAGETYPE}" =~ ^Image.* ]] && [[ $(ls boot/ | grep ^Image.*) ]]; then
        cp boot/Image* "${OUTPUT_DIR}"/
        # Notice: zImage is not support for grub, so make a Image in DEPLOY_DIR_IMAGE for image-live here.
        cp boot/Image* "${DEPLOY_DIR_IMAGE}"/
    fi
    # just neet dir of boot, other in boot is no need.
    rm -rf ./boot/*
    popd
}

copy_openeuler_distro() {
    for IMAGETYPE in ${IMAGE_FSTYPES}
    do
        rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE}
        cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} "${OUTPUT_DIR}"/
    done
}

IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"
