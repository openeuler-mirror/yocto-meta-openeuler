SUMMARY = "A small image just capable of allowing a device to boot."

# no any image features to get minimum rootfs
IMAGE_FEATURES = "empty-root-password"

include recipes-core/images/image-early-config-${MACHINE}.inc
require openeuler-image-common.inc

# not build sdk
deltask populate_sdk

# PACKAGE_INSTALL is the final var to control what is installed in rootfs
PACKAGE_INSTALL = " \
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
