delete_unneeded_from_rootfs() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cd "${IMAGE_ROOTFS}"
    cp -r boot/* "${OUTPUT_DIR}"
    # just need the boot dir, others in boot are not needed to reduce the size of image.
    rm -rf ./boot/*
    cd -
    set +x
}
IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"

copy_rockchip_distro() {
    set -x
    for IMAGETYPE in ${IMAGE_FSTYPES}
    do
        rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE}
        cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} ${OUTPUT_DIR}/
    done
    set +x
}
IMAGE_POSTPROCESS_COMMAND += "copy_rockchip_distro;"

# make no login
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -f ./etc/inittab ]; then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}

IMAGE_FSTYPES:remove = "iso wic tar.gz"
IMAGE_FSTYPES_DEBUGFS = "ext4"
