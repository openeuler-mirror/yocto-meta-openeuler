delete_boot_from_rootfs() {
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    cd "${IMAGE_ROOTFS}"
    if [ -d ./boot ];then
        rm -f "${OUTPUT_DIR}"/*Image* "${OUTPUT_DIR}"/vmlinux*
        mv boot/${KERNEL_IMAGETYPE}-* "${OUTPUT_DIR}"/${KERNEL_IMAGETYPE}
        mv boot/vmlinux* "${OUTPUT_DIR}"/
        rm -r ./boot
    fi
    cd -
}

copy_openeuler_distro() {
    rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES}
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES} "${OUTPUT_DIR}"/
}

IMAGE_PREPROCESS_COMMAND += "delete_boot_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"


#IMAGE_FEATURES += "splash"
IMAGE_FSTYPES = "rpi-sdimg"
SDIMG_ROOTFS_TYPE = "ext4"
EXTRA_IMAGECMD_ext4 += "-E no_copy_xattrs"

# add /init symlink to rootfs, refer to IMAGE_CMD_cpio
IMAGE_PREPROCESS_COMMAND += "add_init_to_rootfs;"

add_init_to_rootfs() {
    if [ "${IMAGE_BUILDING_DEBUGFS}" != "true" ]; then
        if [ ! -L ${IMAGE_ROOTFS}/init ] && [ ! -e ${IMAGE_ROOTFS}/init ]; then
            if [ -L ${IMAGE_ROOTFS}/sbin/init ] || [ -e ${IMAGE_ROOTFS}/sbin/init ]; then
                ln -sf /sbin/init ${IMAGE_ROOTFS}/init
            else
                touch ${IMAGE_ROOTFS}/init
            fi
        fi
    fi 
}
