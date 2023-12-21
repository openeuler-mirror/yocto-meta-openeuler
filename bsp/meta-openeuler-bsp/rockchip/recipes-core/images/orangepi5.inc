#image configuration for orangepi5
delete_unneeded_from_rootfs() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cp ${IMAGE_ROOTFS}/boot/vmlinux* ${OUTPUT_DIR}/
}
IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"
