delete_unneeded_from_rootfs() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cp ${IMAGE_ROOTFS}/boot/vmlinux* ${OUTPUT_DIR}/
}
IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"

IMAGE_POSTPROCESS_COMMAND:append = " mov_rkupdateimg;"
mov_rkupdateimg() {
    cp -fp ${IMGDEPLOYDIR}/rootfs.img ${OUTPUT_DIR}/
    cp -fp ${IMGDEPLOYDIR}/update.img ${OUTPUT_DIR}/
    cp -fp ${DEPLOY_DIR_IMAGE}/boot.img ${OUTPUT_DIR}/
}

IMAGE_FSTYPES:remove = "tar.gz"
IMAGE_FSTYPES_DEBUGFS = "ext4"
