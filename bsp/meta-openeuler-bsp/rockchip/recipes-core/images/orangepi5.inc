#image configuration for orangepi5
delete_unneeded_from_rootfs() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cp ${IMAGE_ROOTFS}/boot/vmlinux* ${OUTPUT_DIR}/
}
IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"

# mv image to pointed place with format in end of sdimg type
mv_image_to_sdimg() {
    # set IMAGE_COMPLETE_DIR to deploy-openeuler-image-image-complete for cp line code format
    IMAGE_COMPLETE_DIR=${WORKDIR}/deploy-openeuler-image-image-complete
    cp -fp ${IMAGE_COMPLETE_DIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic ${OUTPUT_DIR}/${IMAGE_NAME}.sdimg
}
IMAGE_POSTPROCESS_COMMAND += "mv_image_to_sdimg;"
