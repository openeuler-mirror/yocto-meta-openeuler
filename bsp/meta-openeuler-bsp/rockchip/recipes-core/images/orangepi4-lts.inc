#image configuration for orangepi4-lts
delete_unneeded_from_rootfs() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cp ${IMAGE_ROOTFS}/boot/vmlinux* ${OUTPUT_DIR}/
    rm ${IMAGE_ROOTFS}/boot/vmlinux*
    set +x
}
IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"

# mv image to pointed place with format in end of sdimg type
mv_image_to_sdimg() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic "${OUTPUT_DIR}"
}
IMAGE_POSTPROCESS_COMMAND += "mv_image_to_sdimg;"
