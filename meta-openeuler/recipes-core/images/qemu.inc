
# common image fs type for qemu targets
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"

# the qemu rootfs type should be cpio.gz, however IMAGE_FSTYPS add append operation with "iso", so when parse
# IMAGE_FSTYPES finally, it can be set "cpio.gz iso", in order to drop "iso" from IMAGE_FSTYPES we add remove 
# operation with "iso"
IMAGE_FSTYPES:remove = "iso"
IMAGE_FSTYPES_DEBUGFS:remove = "iso"

delete_unneeded_from_rootfs() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cd "${IMAGE_ROOTFS}"
    num_files=$(ls -A "boot" | wc -l)
    if [ "$num_files" != 0 ]; then
        cp -r boot/* "${OUTPUT_DIR}"
        # just need the boot dir, others in boot are not needed to reduce the size of image.
        rm -rf ./boot/*
    fi
    cd -
    set +x
}

copy_openeuler_distro() {
    set -x
    for IMAGETYPE in ${IMAGE_FSTYPES}
    do
        rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE}
        cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} "${OUTPUT_DIR}"/
    done
    set +x
}

IMAGE_PREPROCESS_COMMAND += "delete_unneeded_from_rootfs;"
IMAGE_POSTPROCESS_COMMAND += "copy_openeuler_distro;"

IMAGE_CLASSES += "qemuboot"
