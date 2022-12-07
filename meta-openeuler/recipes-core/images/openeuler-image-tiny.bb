# no host package for image-tiny
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "A small image just capable of allowing a device to boot."

require openeuler-image-common.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
"

# make no login
set_permissions_from_rootfs_append() {
    cd "${IMAGE_ROOTFS}"
    if [ -f ./etc/inittab ]; then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}
