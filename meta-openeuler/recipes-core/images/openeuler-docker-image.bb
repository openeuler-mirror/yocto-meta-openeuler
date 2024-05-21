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

# we only need the raw file system as the input of OCI image,
# so we don't need any fstypes
IMAGE_FSTYPES = ""

do_generate_docker_image() {
    # to solve the problem that the output directory does not exist
    [ -d "${OUTPUT_DIR}" ] || mkdir -p ${OUTPUT_DIR}
    cd ${OUTPUT_DIR}
    # create oci image layout as the workspace,
    # the layout name should be the same as the image name
    umoci init --layout openeuler-oci-image
    # create the image, default to have tag "latest"
    umoci new --image openeuler-oci-image:latest
    # unpack the image into a runtime bundle, so that we can modify it
    sudo umoci unpack --image openeuler-oci-image:latest bundle
    # copy the rootfs into the bundle
    sudo cp -r ${IMAGE_ROOTFS}/* bundle/rootfs/
    # pack the bundle into the image
    sudo umoci repack --image openeuler-oci-image:latest bundle
    # save the oci image into docker image, so that we can use it with docker and isula
    sudo skopeo copy oci:openeuler-oci-image:latest docker-archive:oee-docker-image.${TARGET_ARCH}.tar:oee-docker-image.${TARGET_ARCH}:latest
    # compress the docker image
    xz -z oee-docker-image.${TARGET_ARCH}.tar
    # remove temporary files
    sudo rm -rf bundle
    sudo rm -rf openeuler-oci-image
}

IMAGE_POSTPROCESS_COMMAND:append = "do_generate_docker_image;"

