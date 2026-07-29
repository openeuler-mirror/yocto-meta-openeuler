# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it should not be included by live image

require recipes-core/images/bsp-${MACHINE}.inc

inherit features_check

IMAGE_INSTALL += " \
        kernel-devicetree \
"

# Ensure hi3095.dtb is copied to the latest output directory
IMAGE_POSTPROCESS_COMMAND:append = " copy_hi3095_dtb_to_output;"

copy_hi3095_dtb_to_output() {
    DTB_SRC="${DEPLOY_DIR_IMAGE}/hi3095.dtb"
    if [ ! -f "${DTB_SRC}" ]; then
        bbwarn "hi3095.dtb not found in ${DEPLOY_DIR_IMAGE}, skip."
        return
    fi

    OUTPUT_BASE="${TOPDIR}/output"
    if [ ! -d "${OUTPUT_BASE}" ]; then
        bbwarn "Output base directory ${OUTPUT_BASE} does not exist, skip."
        return
    fi

    LATEST_OUTPUT=$(ls -td ${OUTPUT_BASE}/*/ 2>/dev/null | head -1)
    if [ -z "${LATEST_OUTPUT}" ]; then
        bbwarn "No timestamp subdirectory found in ${OUTPUT_BASE}, skip."
        return
    fi

    install -m 0644 "${DTB_SRC}" "${LATEST_OUTPUT}/hi3095.dtb"
    bbnote "Copied hi3095.dtb to ${LATEST_OUTPUT}"
}
