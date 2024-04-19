SUMMARY = "tiny image ready for generating container image with Dockerfile"

# no any image features to get minimum rootfs
IMAGE_FEATURES = "empty-root-password"

include recipes-core/images/image-early-config-${MACHINE}.inc
require openeuler-image-common.inc

# not build sdk
deltask populate_sdk

# tiny image overwrite this variable, or IMAGE_INSTALL was standard packages in openeuler-image-common.inc file
IMAGE_INSTALL = " \
packagegroup-core-boot \
"

# make install or nologin when using busybox-inittab
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -e ./etc/inittab ];then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}

# for container image, we only need the file system as the input 
# to be transformed into OCI image later using docker in other environment
IMAGE_FSTYPES = "tar.bz2"

do_generate_docker_file() {
    cd ${OUTPUT_DIR}
    # create Dockerfile, adding the rootfs to scratch image
    cat > Dockerfile << EOF
FROM scratch
ADD ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGE_FSTYPES} /
EOF
}

IMAGE_POSTPROCESS_COMMAND += "do_generate_docker_file;"


