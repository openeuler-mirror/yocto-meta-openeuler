copy_bootloader() {
    if [ ! -d ${OUTPUT_DIR} ];then
        mkdir -p ${OUTPUT_DIR}
    fi
    cp ${DEPLOY_DIR_IMAGE}/bl2_bp-${MACHINE}_pmic.srec ${OUTPUT_DIR}/
    cp ${DEPLOY_DIR_IMAGE}/fip-${MACHINE}_pmic.srec ${OUTPUT_DIR}/
    cp ${DEPLOY_DIR_IMAGE}/*.mot ${OUTPUT_DIR}/
    # copy kernel
    cp -L ${DEPLOY_DIR_IMAGE}/Image ${OUTPUT_DIR}/
    # copy uboot
    cp -L ${DEPLOY_DIR_IMAGE}/u-boot.bin ${OUTPUT_DIR}/
    # copy dtb
    cp -L ${DEPLOY_DIR_IMAGE}/*.dtb ${OUTPUT_DIR}/
}
IMAGE_PREPROCESS_COMMAND += "copy_bootloader;"
