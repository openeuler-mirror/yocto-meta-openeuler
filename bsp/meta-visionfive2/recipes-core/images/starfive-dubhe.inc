IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_FSTYPES:remove = "iso"

# create OUTPUTDIR for holding final image
# remove unnecessary files from rootfs to reduce size
delete_unneeded_from_rootfs() {
    set -x
    # if the output_dir does not exist, rm will cause an error
    if test -d "${OUTPUT_DIR}"; then
        rm -rf "${OUTPUT_DIR}"
    else
        mkdir -p "${OUTPUT_DIR}"
    fi
    # if the ${IMAGE_ROOTFS}/boot does not exist, cp will cause an error
    if [ "$(ls ${IMAGE_ROOTFS}/boot)" ]; then
        cp ${IMAGE_ROOTFS}/boot/* ${OUTPUT_DIR}/
        rm ${IMAGE_ROOTFS}/boot/*
    fi
    set +x
}


# We only need to copy the wic image to the output directory
copy_openeuler_distro() {
    set -x
    # if the output_dir does not exist, rm will cause an error
    if test -d "${OUTPUT_DIR}"; then
        rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic.bz2
    else
        mkdir -p "${OUTPUT_DIR}"
    fi
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic.bz2 "${OUTPUT_DIR}"/
    set +x
}

IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"