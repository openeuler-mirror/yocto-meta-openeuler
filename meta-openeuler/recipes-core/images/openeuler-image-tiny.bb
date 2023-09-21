# no host package for image-tiny
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "A small image just capable of allowing a device to boot."

# no any image features to get minimum rootfs
IMAGE_FEATURES = ""

require openeuler-image-common.inc

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

