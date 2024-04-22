# mv image to pointed place with format in end of sdimg type
IMAGE_POSTPROCESS_COMMAND:append = "mov_image_to_sdimg;"
mov_image_to_sdimg() {
    cp -fp ${IMGDEPLOYDIR}/update.img ${OUTPUT_DIR}/
    # ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic
}

IMAGE_FSTYPES:remove = "tar.gz"
IMAGE_FSTYPES_DEBUGFS = "ext4"
