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
